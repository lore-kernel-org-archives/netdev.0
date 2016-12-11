From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Sun, 11 Dec 2016 15:50:31 +0100
Message-ID: <CAHmME9q5ifwwishXjXYE3J=sVeR4jYY9fLUgs_FHCP594EZr6g@mail.gmail.com>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
 <87vauvhwdu.fsf@alice.fifthhorseman.net> <CE942916-BF45-44CC-A5F5-3838CF9C93BC@danrl.com>
 <20161211071501.GA32621@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Dan_L=C3=BCdtke?= <mail@danrl.com>,
        Willy Tarreau <w@1wt.eu>,
        =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        WireGuard mailing list <wireguard@lists.zx2c4.com>,
        Greg KH <gregkh@linuxfoundation.org>,
        Felix Fietkau <nbd@nbd.name>, Jiri Benc <jbenc@redhat.com>,
        David Miller <davem@davemloft.net>
To: linux-mips@linux-mips.org, Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161211071501.GA32621@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey guys,

Thanks for the extremely detailed answers. The main take-away from
this is that passing unaligned packets to the networking stack kills
kittens. So now it's a question of mitigation. I have three options:

1. Copy the plaintext to three bytes before the start of the cipher
text, overwriting parts of the header that aren't actually required.
Pros: no changes required, MTU stays small.
Cons: scatterwalk's fast paths aren't hit, which means two page table
mappings are taken instead of one. I have no idea if this actually
matters or will slow down anything relavent.

2. Add 3 bytes to the plaintext header, set to zero, marked for future use.
Pros: satisfies IETF mantras and makes unaligned in-place decryption
straightforward.
Cons: lowers MTU, additional unauthenticated cleartext bits in the
header are of limited utility in protocol.

3. Add 3 bytes of padding, set to zero, to the encrypted section just
before the IP header, marked for future use.
Pros: satisfies IETF mantras, can use those extra bits in the future
for interesting protocol extensions for authenticated peers.
Cons: lowers MTU, marginally more difficult to implement but still
probably just one or two lines of code.

Of these, I'm leaning toward (3).

Anyway, thanks a lot for the input. "Doing nothing" is no longer under
serious consideration, thanks to your messages.

Thanks,
Jason
