From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: IGMP Join dropping multicast packets
Date: Wed, 18 Mar 2009 08:38:14 +0100
Message-ID: <49C0A4E6.7030703@cosmosbay.com>
References: <91bdcedb0903141316j2dbf4160wb348a5a9e3bde8ad@mail.gmail.com>	 <49BC69D5.5000002@cosmosbay.com>	 <91bdcedb0903151904x1066ac24h63557b588e7c4967@mail.gmail.com>	 <49BEA1ED.4010907@cosmosbay.com> <91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	jeffrey.t.kirsher@intel.com, david.graham@intel.com
To: Dave Boutcher <daveboutcher@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40070 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbZCRHi0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 03:38:26 -0400
In-Reply-To: <91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Boutcher a =E9crit :
> On Mon, Mar 16, 2009 at 2:01 PM, Eric Dumazet <dada1@cosmosbay.com> w=
rote:
>> Dave Boutcher a =E9crit :
>>> On Sat, Mar 14, 2009 at 9:37 PM, Eric Dumazet <dada1@cosmosbay.com>=
 wrote:
>>>> Dave Boutcher a =E9crit :
>>>>> I'm running into an interesting problem with joining multiple
>>>>> multicast feeds.  If you join multiple multicast feeds using
>>>>> setsockopt(...,IP_ADD_MEMBERSHIP...) it causes packets on UNRELAT=
ED
>>>>> multicast feeds to get dropped.  We have a multicast feed on a ro=
ck
>>>>> solid network, and we were very surprised to see dropped packets.=
  The
>>>>> cause was a different process/program being run by a different us=
er
>>>>> joining a bunch of mulitcast feeds.
>>>> I could not reproduce the problem on my machines (bnx2 adapter), e=
ven if changing
>>>> NUMSOCK from 55 to 200 in joiner.c
>>> Thanks for trying Eric.  Based on your email I did some more testin=
g
>>> and thus far I've
>>> only recreated this on x86_64 arches, not on i386.  Which arch did =
you
>>> try it on?
>> I tried both, 32 and 64 bit kernels. No problems so far.
>>
>> Could you post a linux kernel .config of a non 'working' machine, an=
d dmesg output ?
>=20
> Eric, based on your inability to recreate this, I tried on some other
> hardware I had lying around that has an AMD chipset built-in NIC.
> I could not recreate the problem on that hardware.  I'm starting to
> think this is an e1000 problem.  In both the e1000 and e1000e
> drivers they do the following logic:
>=20
>       /* clear the old settings from the multicast hash table */
>=20
>        for (i =3D 0; i < mta_reg_count; i++) {
>                E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
>                E1000_WRITE_FLUSH();
>        }
>=20
>        /* load any remaining addresses into the hash table */
>=20
>        for (; mc_ptr; mc_ptr =3D mc_ptr->next) {
>                hash_value =3D e1000_hash_mc_addr(hw, mc_ptr->da_addr)=
;
>                e1000_mta_set(hw, hash_value);
>        }
>=20
> There's clearly a window where the NIC doesn't have the multicast
> addresses loaded.  This may just be broken-as-designed.  If anyone
> else happens to have some e1000 hardware and wants to see if you
> can recreate this, I'd be curious.
>=20

Ouch, you are probably right, this code needs a change.

tg3 for example has a loop bulding hash values in a local array,
then a write of this array on NIC.

                for (i =3D 0, mclist =3D dev->mc_list; mclist && i < de=
v->mc_count;
                     i++, mclist =3D mclist->next) {

                        crc =3D calc_crc (mclist->dmi_addr, ETH_ALEN);
                        bit =3D ~crc & 0x7f;
                        regidx =3D (bit & 0x60) >> 5;
                        bit &=3D 0x1f;
                        mc_filter[regidx] |=3D (1 << bit);
                }

                tw32(MAC_HASH_REG_0, mc_filter[0]);
                tw32(MAC_HASH_REG_1, mc_filter[1]);
                tw32(MAC_HASH_REG_2, mc_filter[2]);
                tw32(MAC_HASH_REG_3, mc_filter[3]);
        }

Other example , on bnx2, same logic :

               memset(mc_filter, 0, 4 * NUM_MC_HASH_REGISTERS);

                for (i =3D 0, mclist =3D dev->mc_list; mclist && i < de=
v->mc_count;
                     i++, mclist =3D mclist->next) {

                        crc =3D ether_crc_le(ETH_ALEN, mclist->dmi_addr=
);
                        bit =3D crc & 0xff;
                        regidx =3D (bit & 0xe0) >> 5;
                        bit &=3D 0x1f;
                        mc_filter[regidx] |=3D (1 << bit);
                }

                for (i =3D 0; i < NUM_MC_HASH_REGISTERS; i++) {
                        REG_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
                               mc_filter[i]);
                }



> Some other notes just FYI...
>=20
> - RcvbufErrors in /proc/net/snmp doesn't get incremented when this ha=
ppens
> - there are no messages in dmesg
> - frames get dropped when the program calls exit() and all the socket=
s
> get closed
>   (and multicast joins dropped) as well as when the ADD_MEMBERSHIPs h=
appen
> - The problem happens even when adding a sleep(1) in between each of =
the
>   ADD_MEMBERSHIP calls.
>=20


