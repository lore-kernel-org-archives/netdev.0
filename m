From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Wed, 18 Oct 2006 11:15:11 +0200
Message-ID: <200610181115.12471.dpc@asn.pl>
References: <200610151820.22867.dpc@asn.pl> <17717.40394.531846.695392@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:31188 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S932151AbWJRJPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 05:15:51 -0400
To: "Stephen J. Bevan" <stephen@dino.dnsalias.com>
In-Reply-To: <17717.40394.531846.695392@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, 18 October 2006 05:21, you wrote:
> Dawid Ciezarkiewicz writes:
>  >  I'd be thankful for your opinions about that idea. Please forgive me any
>  > nuances that I didn't know about.
> 
> * I suggest extending the documentation with some motivating examples
>   of why someone would want to use this rather than IPsec for IP
>   and/or in what scenarios you'd envisage someone wanting to encrypt
>   ARP, PPPoE, ... etc.  Perhaps, you can somehow mesh it with 802.1x
>   to provide link-level encryption to augment 802.1x link-level
>   authentication?

You're right. I'll add such documentation. For now - short version: as a 
company dealing with wifi regularly we often come to a problem - using wifi 
bridges with strengths like price, "CE included", easy integration, good 
bandwidth, distance etc. - that those devices regularly have max eth mtu 
1500, not much cpu power and are often so feature-less that there are many 
problems with good traffic security. It enforces to use upper level 
encryption with internal fragmentation which is problem because of more more 
frames that those bridges have to handle, bigger traffic etc.

We think that solution like ccrypt will be far more secure and simple - and 
allows to maximize bandwidth and packet per second rate.

> * Your implementation allows the key to be changed but not in a way
>   that allows both sides to do so without disrupting traffic i.e. you
>   don't have something akin to IKE phase2 re-keying.  Without that
>   then if someone can sniff the traffic long enough they are going to
>   get a big sample of data to try and crack the keys with.

Well - ccrypt allows to change keys without disrupting traffic. It works like 
this: first new ccrypt_rx alg:key pair is added. After that ccrypt_rx will 
still use old alg:key, but all unmatched frames will be challenged against 
new one too. Then as soon as possible ccrypt_tx should have that new alg:key 
pair added. When ccrypt_rx gets new frame sent by new alg:key it will not 
match old alg:key, but will match new one. Receiver will switch then and from 
now on it will use only new pair.

This allows key switching without loosing any frames. It should be done 
quickly, since when in "key transition" state all invalid/spoofed frames have 
double cpu impact on receiver. Shouldn't be a problem because attacker should 
have no clue about when key is being switched.

As device ccrypt_rx and tx are independent traffic encryption can use 
independent keys in both traffic directions. And because they use pairs of 
alg:key, in each change: algorithm, key and key length can be changed at 
once. AFAIK attacker have no way to tell where such change occurs nor what 
are parameters of current alg:key.

The idea is to change keys regularly on both sides with userspace tools - like 
ssh on separate vlan, or even simpler static key rotation algorithms or 
something like it. This should allow secure alg:key switching with about any 
frequency.

I hope this will make cracking keys hard enough for attacker that it will not 
even try. Integrity security is more difficult (and possibly weaker) part of 
ccrypt.

> * You write "frames will be delivered in order, so on the other side
>   IV can be always in sync."  If any switches between the two linux
>   boxes are running any kind of link aggregation then you can't
>   guarantee that the frames will be delivered in order.  IEEE 802.3ad
>   requires that packets belonging to the same session travel down the
>   same port to avoid re-ordering but implementations vary as to
>   whether they actually guarantee it or not since most higher level
>   protcols can survive some re-ordering.

I was not aware of that. Thanks. I will add this info to documentation. There 
is nothing actually I can do about that in the form that ccrypt is mean to be 
now.

> * Given your desire not to change the size of the payload you have no
>   space for MAC.  This makes it easier (but by no means easy) to alter
>   the payload in such a way that it is still decrypted and considered
>   valid.

Could you explain it more? I don't understand. You mean MAC as ... ?

> * For the same reason as above you don't have a sequence number.  This
>   combined with the lack of MAC weakens the defense against replay
>   attacks i.e. where third party captures a packet and then re-sends
>   it at a later time.  The fact that IVs must be in sync for the
>   packet to be accepted makes it harder for an attacker but since they
>   know how the IV is calculated they know what message to look for
>   before replaying a packet.

Maybe because of previous one I don't clearly understand the mechanisms. 
Please - if you could explain it more - that knowledge would be very useful, 
and I could put it into the docs too.

> * A variation of the above is that the attacker doesn't care about
>   injecting packets per se, rather they use the above to cause packet
>   loss by causing the receiver to update its IV based on a replayed
>   packet thereby causing the next "real" packet to be dropped because
>   the IV is out of sync.

Yes. This one is possible and I understand that. Maximizing validation 
strictness will cause such attacks to be less efficient and since attacker 
has to have access to the medium of transmition (no matter is it ethernet 
cable or wireless frequency) it could just use much simpler and efficient 
methods.

But I'm still think reporting detection of such attack is trivial and I'll add 
it soon.
