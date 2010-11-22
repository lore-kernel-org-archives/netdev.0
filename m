From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iwl3945: regression - unregister_netdevice: waiting for wlan0
 to become free. Usage count = 1
Date: Mon, 22 Nov 2010 12:19:36 +0100
Message-ID: <1290424776.2811.32.camel@edumazet-laptop>
References: <20101122104341.GA3897@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michal Hocko <mhocko@suse.cz>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101122104341.GA3897@tiehlicka.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 22 novembre 2010 =C3=A0 11:43 +0100, Michal Hocko a =C3=A9crit=
 :
> Hi,
> I am experiencing iwl3945 driver reference counting problem with the =
current
> 2.6.37-rc2 kernel release.=20
>=20
> The problem can be easily reproduced by associating to an AP (I have
> tried only wep and wpa based auth) and then rmmod iw3945 which gets
> stuck in unregister_netdevice (in the endless loop as there is no way=
 -
> I guess - to decrease the reference count to 0) spitting the followin=
g
> message:
>=20
> unregister_netdevice: waiting for wlan0 to become free. Usage count =3D=
 1
>=20
> The situation is even worse as the rmmod process sits on the CPU and
> cannot be killed and the loop never ends so the only solution is
> rebooting.
>=20
> 2.6.37-rc1 looks good. I have tried to bisect to the culprit but I am
> failing to boot some of the kernels on the way (due to some unrelated
> issue which is already fixed in rc2). This is a partial bisect log
> (maybe it helps to narrow down the range of commits):
>=20
> $ git bisect log
> git bisect start
> # bad: [e53beacd23d9cb47590da6a7a7f6d417b941a994] Linux 2.6.37-rc2
> git bisect bad e53beacd23d9cb47590da6a7a7f6d417b941a994
> # good: [151f52f09c5728ecfdd0c289da1a4b30bb416f2c] ipw2x00: remove th=
e right /proc/net entry
> git bisect good 151f52f09c5728ecfdd0c289da1a4b30bb416f2c
> # good: [891cbd30ef456664e50bbd28436ef3006a81cf7c] Merge branch 'upst=
ream/core' of git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen
> git bisect good 891cbd30ef456664e50bbd28436ef3006a81cf7c
> # good: [80ef913f5e6a84551545016cea709f5e96d0cda6] Merge branch 'upst=
ream-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/li=
bata-dev
> git bisect good 80ef913f5e6a84551545016cea709f5e96d0cda6
> # bad: [c22cff08db00ef0411be088956d7934681a1f988] Merge branch 'v4l_f=
or_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linu=
x-2.6
> git bisect bad c22cff08db00ef0411be088956d7934681a1f988
> # skip: [8877870f8a8127b653f8c9a55c6b4de9f96f639b] Merge branch 'mast=
er' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-=
2.6
> git bisect skip 8877870f8a8127b653f8c9a55c6b4de9f96f639b
> # skip: [75e6047431872dadd0b13503b374e48ccd71a507] ucc_geth: Fix dead=
lock
> git bisect skip 75e6047431872dadd0b13503b374e48ccd71a507
> # skip: [18943d292facbc70e6a36fc62399ae833f64671b] inet: fix ip_mc_dr=
op_socket()
> git bisect skip 18943d292facbc70e6a36fc62399ae833f64671b
> [Here I gave up]
>=20
> skipped steps are non-bootable kernels. From the log it looks like th=
e last
> good commit is 80ef913f5e6a845.
>=20
> There is only one patch in that range for iwlwifi drivers:
> $ git shortlog 80ef913f5e6a845..v2.6.37-rc2 -- drivers/net/wireless/i=
wlwifi/
> Wey-Yi Guy (1):
>       iwlwifi: dont use pci_dev before it being assign
>=20
> and this one doesn't look to manipulate the reference counting so I
> guess this is more general problem.
>=20
> $ git shortlog 80ef913f5e6a845..v2.6.37-rc2 -- net/wireless/
> Felix Fietkau (1):
>       cfg80211: fix a crash in dev lookup on dump commands
>=20
> Doesn't look to be the culprit as well, though. Btw. I am getting the
> same patches also in the v2.6.37-rc1..v2.6.37-rc2 range.
>=20
> Please let me know if you need any further information.
> Thanks!


Oh well, it seems David put the fix in net-next-2.6 instead of net-2.6

Please try :

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commitdiff;h=3D9d82ca98f71fd686ef2f3017c5e3e6a4871b6e46

Thanks
