From: Dave Boutcher <daveboutcher@gmail.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Tue, 17 Mar 2009 22:50:21 -0500
Message-ID: <91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>
	 <49BC69D5.5000002@cosmosbay.com>
	 <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>
	 <49BEA1ED.4010907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:27207 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbZCRDuX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 23:50:23 -0400
Received: by an-out-0708.google.com with SMTP id d14so323652and.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 20:50:21 -0700 (PDT)
In-Reply-To: <49BEA1ED.4010907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2009 at 2:01 PM, Eric Dumazet <dada1@cosmosbay.com> wro=
te:
> Dave Boutcher a =E9crit :
>> On Sat, Mar 14, 2009 at 9:37 PM, Eric Dumazet <dada1@cosmosbay.com> =
wrote:
>>> Dave Boutcher a =E9crit :
>>>> I'm running into an interesting problem with joining multiple
>>>> multicast feeds. =A0If you join multiple multicast feeds using
>>>> setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELATE=
D
>>>> multicast feeds to get dropped. =A0We have a multicast feed on a r=
ock
>>>> solid network, and we were very surprised to see dropped packets. =
=A0The
>>>> cause was a different process/program being run by a different use=
r
>>>> joining a bunch of mulitcast feeds.
>>> I could not reproduce the problem on my machines (bnx2 adapter), ev=
en if changing
>>> NUMSOCK from 55 to 200 in joiner.c
>>
>> Thanks for trying Eric. =A0Based on your email I did some more testi=
ng
>> and thus far I've
>> only recreated this on x86_64 arches, not on i386. =A0Which arch did=
 you
>> try it on?
>
> I tried both, 32 and 64 bit kernels. No problems so far.
>
> Could you post a linux kernel .config of a non 'working' machine, and=
 dmesg output ?

Eric, based on your inability to recreate this, I tried on some other
hardware I had lying around that has an AMD chipset built-in NIC.
I could not recreate the problem on that hardware.  I'm starting to
think this is an e1000 problem.  In both the e1000 and e1000e
drivers they do the following logic:

      /* clear the old settings from the multicast hash table */

       for (i =3D 0; i < mta_reg_count; i++) {
               E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
               E1000_WRITE_FLUSH();
       }

       /* load any remaining addresses into the hash table */

       for (; mc_ptr; mc_ptr =3D mc_ptr->next) {
               hash_value =3D e1000_hash_mc_addr(hw, mc_ptr->da_addr);
               e1000_mta_set(hw, hash_value);
       }

There's clearly a window where the NIC doesn't have the multicast
addresses loaded.  This may just be broken-as-designed.  If anyone
else happens to have some e1000 hardware and wants to see if you
can recreate this, I'd be curious.

Some other notes just FYI...

- RcvbufErrors in /proc/net/snmp doesn't get incremented when this happ=
ens
- there are no messages in dmesg
- frames get dropped when the program calls exit() and all the sockets
get closed
  (and multicast joins dropped) as well as when the ADD_MEMBERSHIPs hap=
pen
- The problem happens even when adding a sleep(1) in between each of th=
e
  ADD_MEMBERSHIP calls.

--=20
Dave B
