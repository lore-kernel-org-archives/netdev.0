From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] vmxnet3: Don't enable vlan filters in promiscuous mode.
Date: Wed, 10 Aug 2011 08:16:20 +0800
Message-ID: <CAEP_g=-dwrhuJddX9Jq1yLuUrH0XKwuEdknOHipdZx8dB64xdg@mail.gmail.com>
References: <1312794947-3163-1-git-send-email-jesse@nicira.com> <alpine.LRH.2.00.1108091426010.27839@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Scott Goldman <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:49655 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851Ab1HJAQk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 20:16:40 -0400
Received: by gya6 with SMTP id 6so367472gya.19
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 17:16:40 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1108091426010.27839@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2011 at 5:32 AM, Shreyas Bhatewara
<sbhatewara@vmware.com> wrote:
>
>
> On Mon, 8 Aug 2011, Jesse Gross wrote:
>
>> @@ -1929,14 +1929,17 @@ static void
>> =C2=A0vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct vmxnet3_adapter *adapter =3D netdev_priv=
(netdev);
>> - =C2=A0 =C2=A0 u32 *vfTable =3D adapter->shared->devRead.rxFilterCo=
nf.vfTable;
>> - =C2=A0 =C2=A0 unsigned long flags;
>>
>> - =C2=A0 =C2=A0 VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
>> - =C2=A0 =C2=A0 spin_lock_irqsave(&adapter->cmd_lock, flags);
>> - =C2=A0 =C2=A0 VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0VMXNET3_CMD_UPDATE_VLAN_FILTERS);
>> - =C2=A0 =C2=A0 spin_unlock_irqrestore(&adapter->cmd_lock, flags);
>> + =C2=A0 =C2=A0 if (!(netdev->flags & IFF_PROMISC)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u32 *vfTable =3D adapter=
->shared->devRead.rxFilterConf.vfTable;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long flags;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VMXNET3_SET_VFTABLE_ENTR=
Y(vfTable, vid);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&adapt=
er->cmd_lock, flags);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 VMXNET3_WRITE_BAR1_REG(a=
dapter, VMXNET3_REG_CMD,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0VMXNET3_CMD_=
UPDATE_VLAN_FILTERS);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&=
adapter->cmd_lock, flags);
>> + =C2=A0 =C2=A0 }
>>
>
> If this is done, the driver will ignore all vlan tag registrations (a=
nd
> deletions) while the interface is in promiscuous mode. Better solutio=
n
> would be to send UPDATE_VLAN_FILTERS command alone inside the promisc=
uous
> condition. vfTable can be set/unset unconditionally as before. By doi=
ng
> this, when the interface comes out of promiscuous mode, the restored =
vlan
> state will have all the added/removed vlan tags into effect.

Adds and removes are not ignored when in promiscuous mode because the
active_vlans bitfield is still being updated (this is in the context
that you clipped out).  When we come out of promiscuous mode,
vmxnet3_restore_vlan() is called which will update the hardware with
the vlans that have been registered.  This is much safer than directly
updating vfTable because it will get overwritten if vmxnet3_set_mc()
is called again and is potentially very error prone to have it not
reflect what we actually want programmed in the hardware.
