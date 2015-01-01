From: Julian Kirsch <kirschju@sec.in.tum.de>
Subject: Re: [PATCH] TCP: Add support for TCP Stealth
Date: Fri, 02 Jan 2015 00:31:53 +0100
Message-ID: <54A5D8E9.1020308@sec.in.tum.de>
References: <54A470B3.3010501@sec.in.tum.de> <20150101111030.1e2b3a18@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Christian Grothoff <christian@grothoff.org>,
	Jacob Appelbaum <jacob@appelbaum.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.informatik.tu-muenchen.de ([131.159.0.99]:38214 "EHLO
	smtp1.informatik.tu-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751461AbbAAXb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 18:31:58 -0500
In-Reply-To: <20150101111030.1e2b3a18@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Stephen,

thanks a lot for your input. I've reflected your suggestions in the
code: The mode member of the stealth struct is now a u8, integrity_len
is now unsigned (size_t), I've switched the integrity_len and
integrity_hash members in order to close the gaps in the struct (sorry
for wasting bits) and I removed the cast from the second parameter of
the memcopy you mentioned. While I totally agree with you that the
part of the iv-setup where we xor the hash, tsval and dport in is not
very readable, I'd argue that declaring and using a struct would make
the patch longer while the semantics of such a struct really are
needed only in context of a single function and therefore cannot be
reused. Do you think that accessing the elements with a macro (see
below) could be an alternative?

#define tcp_stealth_iv_integrity_hash(iv)	(((__be16 *)&iv)[2])

Best,
Julian

On 2015-01-01 20:10, Stephen Hemminger wrote:
> On Wed, 31 Dec 2014 22:54:59 +0100 Julian Kirsch
> <kirschju@sec.in.tum.de> wrote:
> 
>> +	memcpy(iv, (const __u8 *)daddr, +	       (daddr_size >
>> sizeof(iv)) ? sizeof(iv) : daddr_size); + +#ifdef
>> CONFIG_TCP_MD5SIG +	md5 = tp->af_specific->md5_lookup(sk, sk); 
>> +#else +	md5 = NULL; +#endif +	if (likely(sysctl_tcp_timestamps
>> && !md5) || tp->stealth.saw_tsval) +		tsval =
>> tp->stealth.mstamp.stamp_jiffies; + +	((__be16 *)iv)[2] ^=
>> cpu_to_be16(tp->stealth.integrity_hash);
> 
> Cast unnecessary on memcpy arg since it takes void *
> 
> Would be clearer to use a real structure or union not assignment to
> cast to setup iv. -- To unsubscribe from this list: send the line
> "unsubscribe netdev" in the body of a message to
> majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUpdjhAAoJENwkOWttRRA4ZFYIALs7gskvZqlCzFCuNTsJ4js9
7x5OTsuyY5caOIEcveVqYnW2dcOO2Jtwe1QUIOsRo7X6YOEA/8IT6+sJ0fxViLTD
TJAzU670Kcecn7+0cHPAj31yW+t9SHb5BBzMLCJlhSAboMs0YKmkwetqffg013uP
x81OI6kJy6pUCAeBeyyy20QafrIhs5vjEILGf9qSzeoIXRBdpnuH99FzoxEjOkUA
ka4QtrAUh3Uk0s6H8ezcpqvY2bKcz7te8+af5XF+Kz/+DLatoN2x58psxw3irBCw
x18FRVsbgmXY/m3leKilK4ieCyO1LzafRNa674fSW6QtHHMDZwSoYi0kDjSNMRk=
=ke3l
-----END PGP SIGNATURE-----
