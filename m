From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCHv2 next 3/3] ipvlan: Introduce l3s mode
Date: Wed, 14 Sep 2016 11:47:56 -0700
Message-ID: <CAF2d9jh0achCBohYksXxU7W7cs-Qwe6eojSWnqFcDkoMUAXdOA@mail.gmail.com>
References: <1473703312-26757-1-git-send-email-mahesh@bandewar.net>
 <1177f2c5-6c2d-32e1-1628-f272d6b0b5c6@cumulusnetworks.com>
 <CAF2d9jgEOsSEQXOVJWJsw=RMdr27YiTdcMPrZ6P2EopqU8wtkw@mail.gmail.com> <14bd5ab7-9206-1399-01c3-4b4ed06ce6f9@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:35595 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753804AbcINSsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 14:48:22 -0400
Received: by mail-yw0-f174.google.com with SMTP id u82so32377168ywc.2
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 11:48:22 -0700 (PDT)
In-Reply-To: <14bd5ab7-9206-1399-01c3-4b4ed06ce6f9@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 11:04 AM, David Ahern <dsa@cumulusnetworks.com> wro=
te:
[...]
>>>> +     ASSERT_RTNL();
>>>>       if (port->mode !=3D nval) {
>>>> +             if (nval =3D=3D IPVLAN_MODE_L3S) {
>>>> +                     port->dev->l3mdev_ops =3D &ipvl_l3mdev_ops;
>>>> +                     port->dev->priv_flags |=3D IFF_L3MDEV_MASTER;
>>>> +                     if (!port->ipt_hook_added) {
>>>> +                             err =3D _nf_register_hooks(ipvl_nfops,
>>>> +                                                     ARRAY_SIZE(ipvl_=
nfops));
>>>
>>> That's clever. The hooks are not device based so why do the register fo=
r each device? Alternatively, you could use a static dst like VRF does for =
Tx. In the ipvlan rcv function set the dst input handler to send the packet=
 back to the ipvlan driver via dst->input. From there send the packet throu=
gh the netfilter hooks and then do the real lookup, update the dst and call=
 its input function. I have working code for VRF driver somewhere that show=
s how to do this.
>>>
>> Do you mean per slave device?  It's registering it for a port (so only
>> once) depending on the mode. If the mode !=3D l3s it wont bother
>> registering to keep current modes as they are.
>
> My reading of the patch the register is called for each ipvlan newlink th=
at uses l3s mode. Adding this debug patch
>
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan=
_main.c
> index d02be277e1db..3f733f1e18ae 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -46,6 +46,7 @@ static int ipvlan_set_port_mode(struct ipvl_port *port,=
 u16 nval)
>                         if (!port->ipt_hook_added) {
>                                 err =3D _nf_register_hooks(ipvl_nfops,
>                                                         ARRAY_SIZE(ipvl_n=
fops));
> +pr_warn("called _nf_register_hooks for dev %s: err %d\n", port->dev->nam=
e, err);
>                                 if (!err)
>                                         port->ipt_hook_added =3D true;
>                                 else
> @@ -54,9 +55,11 @@ static int ipvlan_set_port_mode(struct ipvl_port *port=
, u16 nval)
>                 } else {
>                         port->dev->priv_flags &=3D ~IFF_L3MDEV_MASTER;
>                         port->dev->l3mdev_ops =3D NULL;
> -                       if (port->ipt_hook_added)
> +                       if (port->ipt_hook_added) {
> +pr_warn("calling _nf_unregister_hooks for dev %s\n", port->dev->name);
>                                 _nf_unregister_hooks(ipvl_nfops,
>                                                      ARRAY_SIZE(ipvl_nfop=
s));
> +                       }
>                         port->ipt_hook_added =3D false;
>                 }
>                 list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
>
>
>
> and building, installing and testing I see this:
>
> $ ip link add ipvl1 link eth1 type ipvlan mode l3s
> -->  called _nf_register_hooks for dev eth1: err 0
>
> $ ip link add ipvl2 link eth1 type ipvlan mode l3s
> --> no message generated
>
> $ ip link add ipvl3 link eth2 type ipvlan mode l3s
> --> called _nf_register_hooks for dev eth2: err 0
>
The first newlink (l3s) will register the hook and subsequent newlink
calls will skip registration. This is why you did not see the message
for the ipvl2 link creation. However lpvl3 is a added on top of eth2
while the first two link were added on eth1. So this is new port
creation and hence the driver tried to register the hook again.

>
> But there is more. If I delete all 3 ipvlan devices the nf_unregister is =
not called. Unload the ipvlan module and panic:
>
> [  181.135061] BUG: unable to handle kernel paging request at ffffffffa00=
2cfca
> [  181.137710] IP: [<ffffffffa002cfca>] 0xffffffffa002cfca
> [  181.139574] PGD 1a07067 PUD 1a08063 PMD 1387e4067 PTE 0
> [  181.140964] Oops: 0010 [#1] SMP
> [  181.141684] Modules linked in: 8021q garp mrp stp llc vrf [last unload=
ed: ipvlan]
> [  181.143678] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.8.0-rc6+ #96
> [  181.145092] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.7.5-20140531_083030-gandalf 04/01/2014
> [  181.147340] task: ffff88013f196180 task.stack: ffff88013f19c000
> [  181.148510] RIP: 0010:[<ffffffffa002cfca>]  [<ffffffffa002cfca>] 0xfff=
fffffa002cfca
> [  181.150044] RSP: 0018:ffff88013fc83bd0  EFLAGS: 00010a12
> [  181.151102] RAX: ffff88013a781c88 RBX: ffff88013fc83c08 RCX: 000000000=
0000000
> [  181.152460] RDX: ffff88013fc83c38 RSI: ffff88013ab15600 RDI: 000000000=
0000000
> [  181.153781] RBP: ffff88013fc83bf8 R08: 0000000000004b61 R09: 000000000=
0000004
> [  181.155107] R10: 0000000000000000 R11: ffffea00044d9c80 R12: ffffffff8=
1a89510
> [  181.156426] R13: ffff88013ab15600 R14: ffff88013fc83c38 R15: ffff88013=
ab15600
> [  181.157742] FS:  0000000000000000(0000) GS:ffff88013fc80000(0000) knlG=
S:0000000000000000
> [  181.159232] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  181.160303] CR2: ffffffffa002cfca CR3: 000000013a5de000 CR4: 000000000=
00406e0
> [  181.161588] Stack:
> [  181.161954]  ffffffff813f8b47 ffff88013ab15600 ffff88013ab15600 ffff88=
013fc83c38
> [  181.163353]  ffff88013874ac4e ffff88013fc83c28 ffffffff813f8b8c ffff88=
013a781c88
> [  181.164722]  ffff88013ab15600 ffffffff81a88b00 ffff88013874ac4e ffff88=
013fc83c88
> [  181.166094] Call Trace:
> [  181.166532]  <IRQ>
> [  181.166885]  [<ffffffff813f8b47>] ? nf_iterate+0x41/0x5b
> [  181.167880]  [<ffffffff813f8b8c>] nf_hook_slow+0x2b/0x94
> [  181.168803]  [<ffffffff81400c6e>] ip_local_deliver+0xa4/0xbf
> [  181.169748]  [<ffffffff81400644>] ? xfrm4_policy_check.constprop.8+0x5=
2/0x52
> [  181.170910]  [<ffffffff81400a71>] ip_rcv_finish+0x2ed/0x34a
> [  181.171841]  [<ffffffff81400f02>] ip_rcv+0x279/0x2fb
> ...
>
Probably creating two ports (on two physical interfaces) is not a
common / use case but that doesn't mean kernel should crash either!
>
> Also, another sequence:
> $ ip link add ipvl1 link eth1 type ipvlan mode l3s
> -->  called _nf_register_hooks for dev eth1: err 0
>
> $ ip link add ipvl2 link eth1 type ipvlan mode l3s
> --> no message generated
>
> $ ip link set ipvl2 type ipvlan mode l3
> --> calling _nf_unregister_hooks for dev eth1
>
> that means the hooks are not there for ipvl1. I can remove the module wit=
h no panic.
>
tl;dr you found an issue for sure! The hook registration has to be
global than per port and I'll fix that in the next rev. Thank you for
taking to time to test this.
