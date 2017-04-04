From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: Allow to remove administratively
 set MAC on VFs
Date: Tue, 4 Apr 2017 10:33:39 -0700
Message-ID: <CAKgT0UdYjzk4worxwfpuCEY7c6+n8x1Uqz5_=Az_y1zeK6gCSg@mail.gmail.com>
References: <20170404151055.21447-1-vinschen@redhat.com> <B1C1DF2ACD01FD4881736AA51731BAB2B1E1A2@ORSMSX107.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Corinna Vinschen <vinschen@redhat.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36009 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753798AbdDDRdl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:33:41 -0400
Received: by mail-io0-f196.google.com with SMTP id 68so15707065ioh.3
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 10:33:40 -0700 (PDT)
In-Reply-To: <B1C1DF2ACD01FD4881736AA51731BAB2B1E1A2@ORSMSX107.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 4, 2017 at 10:16 AM, Duyck, Alexander H
<alexander.h.duyck@intel.com> wrote:
>> -----Original Message-----
>> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
>> Behalf Of Corinna Vinschen
>> Sent: Tuesday, April 4, 2017 8:11 AM
>> To: intel-wired-lan@lists.osuosl.org
>> Cc: netdev@vger.kernel.org
>> Subject: [Intel-wired-lan] [PATCH] igb: Allow to remove administratively set MAC
>> on VFs
>>
>>   Before libvirt modifies the MAC address and vlan tag for an SRIOV VF
>>   for use by a virtual machine (either using vfio device assignment or
>>   macvtap passthru mode), it saves the current MAC address and vlan tag
>>   so that it can reset them to their original value when the guest is
>>   done.  Libvirt can't leave the VF MAC set to the value used by the
>>   now-defunct guest since it may be started again later using a
>>   different VF, but it certainly shouldn't just pick any random value,
>>   either. So it saves the state of everything prior to using the VF, and
>>   resets it to that.
>>
>>   The igb driver initializes the MAC addresses of all VFs to
>>   00:00:00:00:00:00, and reports that when asked (via an RTM_GETLINK
>>   netlink message, also visible in the list of VFs in the output of "ip
>>   link show"). But when libvirt attempts to restore the MAC address back
>>   to 00:00:00:00:00:00 (using an RTM_SETLINK netlink message) the kernel
>>   responds with "Invalid argument".
>>
>>   Forbidding a reset back to the original value leaves the VF MAC at the
>>   value set for the now-defunct virtual machine. Especially on a system
>>   with NetworkManager enabled, this has very bad consequences, since
>>   NetworkManager forces all interfacess to be IFF_UP all the time - if
>>   the same virtual machine is restarted using a different VF (or even on
>>   a different host), there will be multiple interfaces watching for
>>   traffic with the same MAC address.
>>
>>   To allow libvirt to revert to the original state, we need a way to
>>   remove the administrative set MAC on a VF, to allow normal host
>>   operation again, and to reset/overwrite the VF MAC via VF netdev.
>>
>>   This patch implements the outlined scenario by allowing to set the
>>   VF MAC to 00:00:00:00:00:00 via RTM_SETLINK on the PF.
>>   igb_ndo_set_vf_mac resets the IGB_VF_FLAG_PF_SET_MAC flag to 0,
>>   so it's possible to reset the VF MAC back to the original value via
>>   the VF netdev.
>>
>>   Note: Recent patches to libvirt allow for a workaround if the NIC
>>   isn't capable of resetting the administrative MAC back to all 0, but
>>   in theory the NIC should allow resetting the MAC in the fisr place.
>
> Minor typo here. I assume you mean "first place".
>
>> Signed-off-by: Corinna Vinschen <vinschen@redhat.com>
>> ---
>>  drivers/net/ethernet/intel/igb/igb_main.c | 25 ++++++++++++++++++++-----
>>  1 file changed, 20 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>> b/drivers/net/ethernet/intel/igb/igb_main.c
>> index 26a821f..e7a61b1 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -8125,12 +8125,27 @@ static int igb_set_vf_mac(struct igb_adapter
>> *adapter,  static int igb_ndo_set_vf_mac(struct net_device *netdev, int vf, u8
>> *mac)  {
>>       struct igb_adapter *adapter = netdev_priv(netdev);
>> -     if (!is_valid_ether_addr(mac) || (vf >= adapter->vfs_allocated_count))
>> +
>> +     if (vf >= adapter->vfs_allocated_count)
>> +             return -EINVAL;
>
> I would add an blank line here just for readability.
>
>> +     /* Setting the VF MAC to 0 reverts the IGB_VF_FLAG_PF_SET_MAC
>> +        flag and allows to overwrite the MAC via VF netdev.  This
>> +        is necessary to allow libvirt a way to restore the original
>> +        MAC after unbinding vfio-pci and reloading igbvf after shutting
>> +        down a VM. */
>
> Minor coding style issue here. The "*/" should be on a separate line.
>
>> +     if (is_zero_ether_addr(mac)) {
>> +             adapter->vf_data[vf].flags &= ~IGB_VF_FLAG_PF_SET_MAC;
>> +             dev_info(&adapter->pdev->dev,
>> +                      "remove administratively set MAC on VF %d\n",
>> +                      vf);
>> +     } else if (is_valid_ether_addr (mac)) {
>> +             adapter->vf_data[vf].flags |= IGB_VF_FLAG_PF_SET_MAC;
>> +             dev_info(&adapter->pdev->dev, "setting MAC %pM on VF
>> %d\n",
>> +                      mac, vf);
>> +             dev_info(&adapter->pdev->dev,
>> +                      "Reload the VF driver to make this change effective.");
>> +     } else
>>               return -EINVAL;
>
> Minor coding style issue here. The else should also have "{}" wrapping the statement. Generally if any one of the statements in an if/else series needs the braces they should all have the braces.
>
>> -     adapter->vf_data[vf].flags |= IGB_VF_FLAG_PF_SET_MAC;
>> -     dev_info(&adapter->pdev->dev, "setting MAC %pM on VF %d\n", mac,
>> vf);
>> -     dev_info(&adapter->pdev->dev,
>> -              "Reload the VF driver to make this change effective.");
>>       if (test_bit(__IGB_DOWN, &adapter->state)) {
>
> You might need to change this to allow us to clear the VF MAC address while the PF is down without the message. It doesn't add much in this case and allowing us to clear it would make sense.
>
>>               dev_warn(&adapter->pdev->dev,
>>                        "The VF MAC address has been set, but the PF device is
>> not up.\n");

So I just realized there is one other minor issue I just found. In
igb_rar_set_qsel you should probably add a check for
"is_valid_ether_addr(addr)" before you set the E1000_RAH_AV bit. For
the zeroed MAC address it should be cleared so that we aren't
filtering on a MAC address of all 0's for the VF.

- Alex
