From: linux@horizon.com
Subject: Re: RFC: Established connections hash function
Date: 24 Mar 2007 08:26:58 -0400
Message-ID: <20070324122658.7240.qmail@science.horizon.com>
Cc: linux@horizon.com
To: johnpol.2ka.mipt.ru@horizon.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:13623 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751862AbXCXM1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 08:27:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Result with jenkins:
> 1 23880
> 2 12108
> 3 4040
> 4 1019
> 5 200
> 6 30
> 7 8
> 8 1
> 
> Xor:
> 1 65536

Precisely.  This means that the Xor hash SUCKS, because its output is conspicuously
non-random.

What you expect is a Poisson distribution, where the chance that a chain will contain
k elements is
	P(lambda,k) = e^-lambda * lambda^k / k!
lambda is the average loading per chain.  In your example, it's 1 (65536 inputs, 65536 outputs).
(^ is exponentiation, ! is factorial)

So the distribution I expect to get is:
 0 24109.347656
 1 24109.347656
 2 12054.673828
 3 4018.224609
 4 1004.556152
 5 200.911224
 6 33.485203
 7 4.783601
 8 0.597950
 9 0.066439
10 0.006644

Whick looks a HELL of a lot like what you observed.
(The jenkins result above has 24250 chains with no entries.)


Now, you can sometimes use properties of the inputs to get a distribution
that is more uniform than random, by letting the distribution of the input
"show through" the hash funciton.  Which the xor hash does.  But this
depends on making assumptions about the input distribution, which means
that you're assuming that they're not being chosen maliciously.

If an attacker is choosing maliciously, which is a required assumption
in today's Internet, the best you can do is random.

Now, the core Jenkins hash mix function basically takes three inputs.
What jhash_3words does with it is:
	a += K
	b += K
	c += seed
	__jhash_mix(a, b, c)
	return c;

Now, the ipv4 hash operation fundamentally involves 96 bits of input,
which is a good match for jhash.  If you want to add a salt, perhaps the
simplest thing would be to just replace those constants K with a 96-bit
salt and be done with it:

	a = (lport<<16) + rport + salt[0];
	Xb = laddr + salt[1];
	c = raddr + salt[2];
	__jhash_mix(a,b,c)
	return c;

Regarding control by attackers, let's consider the four inputs and see
how much information an attacker can insert into each one:

remote port: An attacker has complete control over this.  16 bits.
remote address: Depends on the size of the bit-net.  Can vary from 0 bits
	(one machine) to 20 bits for a large bot-net.
local address: Limited to the number of addresses the local machine has.
	Typically 0 bits, rarely more than 2 bits.
	May be much larger (8 bits or more) for stateful firewalls and
	other sorts of proxies.
local port: Limited to the number of open server ports.  Typically 3-6
	bits, but may be lower on heavily firewalled machines.

Certainly combining any two of these in a predictable way without some
non-linear salting makes an attacker's job easier.  While folding the
local and remote addresses before hashing is usually safe because the
local address is usually unique, there are situations in which there are
a large number of possible local addresses.

For example, it allows an attacker with a /24 to attack, say, a stateful
firewall guarding a /24.  If I have my machine at address a.b.c.d connect
to remote machine x.y.z.~d, then they always fold to a^x.b^y.c^z.255,
and I can, by making the local and remote paorts identical for all the
attacks, force 254-entry hash chains without knowing anything else about
the hash function, salt, or whatever.


An interesting question is whether it's better to mix salt into the
bits an attacker has most or least control over.  It's not immediately
obvious to me; does anyone else have insight?  Just mixing in 96 bits
over everything does seem to render the question moot.
