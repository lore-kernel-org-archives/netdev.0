From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors with	batman-adv
Date: Sun, 01 Dec 2013 15:28:58 +0100
Message-ID: <529B47AA.8060403@meshcoding.com>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <529A46C4.9090906@meshcoding.com> <20131130230518.GC16735@n2100.arm.linux.org.uk> <529A8276.9060002@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:17988 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab3LAO3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Dec 2013 09:29:40 -0500
In-Reply-To: <529A8276.9060002@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/12/13 01:27, Antonio Quartulli wrote:
> On 01/12/13 00:05, Russell King - ARM Linux wrote:
>> On Sat, Nov 30, 2013 at 09:12:52PM +0100, Antonio Quartulli 
>> wrote:
>>> I don't know the ARM architecture at all (I don't know if the 
>>> other batman-adv developers do), so could you please provide 
>>> here some more details about why that static check is failing? 
>>> We would like to address this issue differently rather than 
>>> re-adding the __packed attribute.
> 
>> The reason is this struct becomes a size of 4 bytes, even though 
>> it only contains three uint8_t members.  This offsets the
>> members of all structs that this struct is embedded in.
> 
>> If you don't wish to fix this, then please make your subsystem 
>> depend on !ARM because it's otherwise impossible to fix and can 
>> never work on ARM.
> 
> 
> I'd like to fix this.
> 
> Actually I can't really understand your explanation: struct 
> batadv_header is always used inside another parent structure and 
> the latter always has a uint8_t following the batadv_header, thus 
> filling that gap and aligning it to 4bytes. I think this is also 
> why we don't get this compiler error on any other architecture. Or 
> am I missing something?
> 
> I'll install a toolchain for ARM and I'll try to inspect it
> better. If we have to make a change we should do it before 3.13 is
> release since this change could possibly alter the packet layout.
> 
> 

It looks like that the ARM compiler cannot pack the structures properly.

So, given these two structures:

struct batadv_header {
        uint8_t  packet_type;
        uint8_t  version;
        uint8_t  ttl;
};

struct batadv_unicast_packet {
        struct batadv_header header;
        uint8_t  ttvn;
        uint8_t  dest[ETH_ALEN];
};

we have the compiler saying that offset_of dest in struct
batadv_unicast_packet is 5.

This means that struct batadv_header is padded to 4 bytes even if it
is enclosed in struct batadv_unicast_packet and a proper 1byte member
is put right after it.

Am I wrong or this is a problem in the ARM compiler not doing the
right assumption? On x86 and x86_64 offset_of dest is 4, as expected.


Regards,

- -- 
Antonio Quartulli
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlKbR6oACgkQpGgxIkP9cwdpYACgjcWLZ7EGFDatHTsByPz7idsY
YOgAnRq6JTmOv8zI3OrRiBRtOIprgOew
=Jxbq
-----END PGP SIGNATURE-----
