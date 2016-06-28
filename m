From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [RFC] WireGuard: next generation secure network tunnel
Date: Tue, 28 Jun 2016 16:49:18 +0200
Message-ID: <CAHmME9q-6ioctzcB8gLdYOsMFqHVGY8GUsVGFisKv=wGdVqi2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, linux-crypto@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave & Folks,

Today I'm releasing WireGuard, an encrypted and authenticated
tunneling virtual interface for the kernel. It uses next-generation
cryptography and is designed to be both easy to use and simple to
implement (only ~4000 LoC, which compared to xfrm or openvpn is
spectacular), avoiding the enormous complexities of all other secure
tunneling tools. It's been a long road, but after considerable
research, experiments, cryptographic review, and implementing, I think
I'm at a point where I feel comfortable releasing this and asking for
your feedback. This isn't yet a patch series, however. There's still
some work to be done, I anticipate, before this is mergeable. But what
we have now is a good basis for discussion and talking about what
needs to be done for this to be a proper patch series.

You may visit the main info site about WireGuard at
https://www.wireguard.io and you can read the whitepaper and full
technical description and argumentation at
https://www.wireguard.io/papers/wireguard.pdf . The source code lives
at https://git.zx2c4.com/WireGuard/tree/src/ and you can read
instructions on building it in the install and quickstart sections of
the website. I'm not going to recapitulate all of the paper here, but
I will discuss the things that are most relevant to kernel
development.

WireGuard acts as a virtual interface, doing layer 3 IP tunneling,
addable with "ip link add dev wg0 type wireguard". You can set the
interface's local IP and routes using the usual ip-address and
ip-route tools. The WireGuard-specific elements are in a new tool
called `wg`, which will at some point be merged into the usual ip
tools. With `wg` you can set the device's private key, and give it a
list of associations between peers' public keys, their allowed IP
addresses, and their remote UDP endpoints. When a locally generated
packet hits the device, it looks at the dst IP, looks up this dst IP
in the aforementioned association table, and then encrypts it using
the proper public key's session. Conversely, when an encrypted packet
arrives on the interface, after it's been decrypted, the inner src IP
is looked up in this association table to see if it matches the public
key from which it originated. This is the "cryptokey routing table",
and many more details and explanations are found on the site and paper
above. But that's the basic gist; you add a device with ip-link, give
it keys with `wg`, and then you can start sending and receiving
packets on the interface that are secure.

In order to make this so seamless, WireGuard does away with a lot of
the _theoretically pure_ layering abstractions typically seen. First
of all, WireGuard is an interface, where crypto is done, which is a
considerable departure from the (hugely complex) xfrm-approach. It is
not unprecedented, however; the mac80211 infrastructure also does
crypto at this same layer. The massive gain is not only greater
simplicity in the codebase, but huge simplicity earnings and
ease-of-security for administrators. If a packet comes from a
WireGuard interface, it can be trusted as authentic and confidential.
If you want outgoing packets to be tunneled, point your routing table
at the WireGuard interface. It's basically that simple, removing years
and years of headaches (and catastrophically insecure
misconfigurations) people often have with the xfrm layer.

Second, WireGuard uses something based on the Noise Protocol Framework
(in Noise_IK) for key agreement and handshake, rather than, say,
relegating to a userspace daemon. The reason, again, is massive
simplicity and security savings. The Noise_IK handshake is extremely
simple, and tight integration between the handshake and the transport
layer allows WireGuard itself to handle all session-state and
connection-state and so-forth, making the whole process appear
"stateless" to the administrator (you set it up with `wg`, and then it
_just works_). There is no x509, no ASN.1, no huge complexity; the
user configures the public keys, and then the rest is taken care of.
Other configuration frameworks (based on x509 or SSL or LDAP or
whatever you want) can then build on top of this in userspace, if that
sort of thing is desired. But the basic handshake fundamentals are
left to WireGuard. This is more or less similar to SSH, which cares
about the authorized_keys file.

These two design choices are fundamental to WireGuard, and I believe
they confer significant benefits, which are discussed extensively in
the paper. There are two incidental implementation choices, however,
that I think will be more controversial from a kernel perspective, and
depending on the result of this discussion, maybe things will change,
or maybe they wont.

First, WireGuard doesn't use the kernel's crypto API. The overhead of
memory allocation and abstraction/indirection behind each
encryption/hashing/ec-multiplication operation not only adds
unfortunate performance overhead, but also bloats the code, impacting
ease of auditing and verification. Furthermore, the flexible design of
the kernel's crypto API isn't needed, or even desired, because, as
discussed in the paper, WireGuard uses a fixed set of cryptographic
primitives (ChaCha20, Poly1305, Blake2s, Curve25519). Instead
WireGuard ships its own primitives, with the ChaPoly ones being based
directly on Martin's existing kernel implementations. It does use some
nice aspects of the kernel's crypto layer, though. It makes use of
scatterwalk, blkcipher_walk, crypto_memneq, and padata, with padata in
particular being very nice.

Second, WireGuard initially used Netlink for configuration, but big
limitations and complexities lead to reimplementing it with ioctl
instead. It was really so much cleaner and simpler in the end to do it
that way. Probably upon reading that you're having a panic attack or
an embolism. If, after reviewing the current configuration code
(src/config.c), you have some ideas for a Netlink implementation that
is just as clean and isn't horrible, I'd be happy to return to
Netlink. With considerable hubris, though, I sort of suspect you'll
find the ioctl interface the most clean way. But who knows? I guess
you do.

There are a few code style issues that I'll need to clean up for you
as well. I happen to like long lines, I should probably prefix
non-static function names with "wg_", and I shouldn't make inline
functions outside of headers. But these are silly trivial things that
will get fixed up before it's git-send-email time.

Beyond those issues, I think you'll be rather pleased with WireGuard.
It makes use of a few tricks that are worth noting. I found that the
pattern of "encrypt(packet1), send(packet1), encrypt(packet2),
send(packet2), encrypt(packet3), send(packet3)" was much slower than
"encrypt(packet1), encrypt(packet2), encrypt(packet3), send(packet1),
send(packet2), send(packet3)", because (I suspect) cache misses along
the UDP xmit path. Using the faster pattern, the question is, "how
many packets should we encrypt before sending the list of them?" It
turns out there's no magic number, but rather we can learn this
dynamically due to GSO. The WireGuard driver claims that it can handle
un-segmented GSO "super-packets". When it receives one of these, it
splits it into N packets (using the usual skb_gso_segment() function),
and then encrypts each of these before sending each of them. That way,
the number is related to the way in which userspace is sending
packets. In practice this works very well, in case others would like
to use this technique too.

By the way, the design allows for easy namespace separation, where the
UDP sending/receiving socket can be in one namespace and the virtual
interface itself in another, so that you could, for example, give a
Docker container as its only interface a WireGuard tunnel, ensuring
that the Docker container's only way to get packets out is through the
secure tunnel.

Another neat thing I do is make use of SipHash24. WireGuard has a
hashtable of public keys. These public keys are supplied by userspace,
and thus could be maliciously crafted to create hash collisions. To
prevent against this attack, I use SipHash24, which is
cryptographically secure. This is nothing new; OpenBSD and Python and
a bunch of other projects use SipHash24 exactly the same way. But
aside from WireGuard, I haven't seen it used in the Linux kernel yet.
I'd be happy to put my implementation someplace where it belongs and
convert some other prone-to-poisoning code to use it, if you're
interested.

Generally speaking, though, I try to integrate and re-use as much as
possible. The driver itself is rtnl_link_register()-based. Packets are
sent and received using Tom's udp_tunnel_*() family of functions. ICMP
is handled by the usual icmp_send() functions. Stats utilize the newer
->tstats member. Hashlimit is used via xt_request_find_match() in the
proper way. skb_to_sgvec() is used for avoiding linearization. There's
lots of nice code-reuse, so you'll probably find your favorite goody
from the networking subsystem in there. Sparse is generally happy,
even when checking for endianness. Coverity Scan is happy too. I've
been working with Greg KH (CC'd) to ensure that for kernel code, in
general, WireGuard is up to snuff.

The best thing to do now would be to peruse the documentation, try
making some secure tunnels, and then take a look at the code.  I'm
open to any and all feedback, and remain available for questions and
fixes and so forth, via email, on the mailing list, on IRC (#wireguard
on freenode), or I guess by telephone if you hate typing. In other
words, I'm committed to working with you any which way to get this in
shape for upstream. Right now it builds as a module for Linux >=4.1,
but as we get closer to [PATCH] posting time, I'll likely change
things into a full kernel tree and ditch the backwards-compatibility
#ifdefs. Importantly, though, WireGuard doesn't require any
modifications in other parts of the kernel, making it nicely
standalone. And most of all, the codebase is pretty short; I hope you
find it enjoyable to read.

I look forward to your feedback and comments.

Thank you,
Jason Donenfeld
