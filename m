From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Sun, 22 May 2011 18:39:06 -0700
Message-ID: <m1zkmedwlh.fsf@fess.ebiederm.org>
References: <1302241713-3637-1-git-send-email-jpirko@redhat.com>
	<20110412.141645.112604563.davem@davemloft.net>
	<BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
	<20110521072925.GA2588@jirka.orion>
	<BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
	<4DD7BB61.9050200@gmail.com>
	<BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
	<4DD87C25.4030701@gmail.com> <20110522062915.GA2611@jirka.orion>
	<m17h9jp7js.fsf@fess.ebiederm.org>
	<BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
	<m1ei3qjzix.fsf_-_@fess.ebiederm.org>
	<4DD97A44.2020708@candelatech.com> <m1wrhigy37.fsf@fess.ebiederm.org>
	<BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Nicolas de =?utf-8?Q?Peslo=C3=BCan?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net,
	Jesse Gross <jesse@nicira.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:57796 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab1EWBjP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 21:39:15 -0400
In-Reply-To: <BANLkTinXFYzzj3R97mKH-90xM64BDwN8aA@mail.gmail.com> (Changli
	Gao's message of "Mon, 23 May 2011 08:38:36 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao <xiaosuo@gmail.com> writes:

> On Mon, May 23, 2011 at 6:38 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>>> Many years ago we supported the REORDER, but we suggested disabling
>>> it for most users because it was a performance drag. =C2=A0Funny th=
at now
>>> it seems to be the opposite!
>>
>> Yes it is funny. =C2=A0I looked in history a while back and what I s=
aw was
>> that REORDER was always enabled by default and it took some serious
>> effort to figure out how to get vconfig to disable REORDER. ip doesn=
't
>> admit that REORDER can be disabled at all.
>>
>
> Really?

> Quoted from the manual page of vconfig
>        set_flag [vlan-device] 0 | 1
>               When  1,  ethernet  header  reorders  are turned on. Du=
mping the
>               device will appear as a common ethernet  device  withou=
t  vlans.
>               When  0(default)  however,  ethernet  headers are not r=
eordered,
>               which results in vlan tagged packets when  dumping  the=
  device.
>               Usually the default gives no problems, but some packet =
filtering
>               programs might have problems with it.
>
> reordered is disabled by default. I also concern the performance.
> Untag and then tag are expensive for the NICs which don't support
> hw-accel-vlan-rx/tx.

Yes really the vconfig man page is wrong.  Reorder has been enabled
by default since the code was merged.  See below.

Dhcp among other things does not work if you disable reorder.

As for performace we are moving 12 bytes which should be cache hot
4 bytes later in what should be the same cache line.  I expect my
16Mhz 386 will slow down a little for an operations like that, I
don't expect much else will.  I can't see anything short of benchmark
numbers being persuasive.

The other reality is that the code is honestly and truly broken in
the corner cases.  If we don't consolidate the code paths it will
never operate correctly.

Not that I agree 100% with all of the decisions but the code has
been broken for a while for most users so we really need to make
it consistent and fix the bugs.

=46urthermore to the best of my knowledge no one actually clears
the reorder bit.  Changli the fact that you don't know that the
reorder bit is set by default suggest that you don't clear it
in the cases you are concerned about.

If no one is clearing the reorder bit in practice all that we
really have for the vlan changes are code motion and simplification
which should only have a positive impact on performance.

Eric

Aka the vlan code came in at:

commit 15a435fe2c0f649e2879e51e05fa466c2bb12731
Author: torvalds <torvalds>
Date:   Tue Feb 5 20:30:01 2002 +0000

    v2.4.13.5 -> v2.4.13.6
   =20
      - me: remember to bump the version number ;)
      - Hugh Dickins: export "free_lru_page()" for modules
      - Jeff Garzik: don't change nopage arguments, just make the last =
a dummy one
      - David Miller: sparc and net updates (netfilter, VLAN etc)
      - Nikita Danilov: reiserfs cleanups
      - Jan Kara: quota initialization race
      - Tigran Aivazian: make the x86 microcode update driver happy abo=
ut
      hyperthreaded P4's
      - me: shrink dcache/icache more aggressively
      - me: fix up oom-killer so that it actually works
   =20
    BKrev: 3c6040c9uewuD0S9AwFCfH3_YMyRHQ

[snip]
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
new file mode 100644
index 0000000..e549e33
--- /dev/null
+++ b/net/8021q/vlan.c
[snip]
+/* DO reorder the header by default */
+unsigned short vlan_default_dev_flags =3D 1;

[snip]
+/*  Attach a VLAN device to a mac address (ie Ethernet Card).
+ *  Returns the device that was created, or NULL if there was
+ *  an error of some kind.
+ */
+struct net_device *register_802_1Q_vlan_device(const char* eth_IF_name=
,
+					       unsigned short VLAN_ID)
+{
[snip]
+	VLAN_DEV_INFO(new_dev)->vlan_id =3D VLAN_ID; /* 1 through 0xFFF */
+	VLAN_DEV_INFO(new_dev)->real_dev =3D real_dev;
+	VLAN_DEV_INFO(new_dev)->dent =3D NULL;
+	VLAN_DEV_INFO(new_dev)->flags =3D vlan_default_dev_flags;
[snip]
