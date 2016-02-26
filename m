From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] be2net: don't {en,dis}able filters on BE3 when
 transparent tagging is enabled
Date: Fri, 26 Feb 2016 13:24:40 +0100
Message-ID: <56D04408.8070306@redhat.com>
References: <1456476401-23398-1-git-send-email-ivecera@redhat.com>
 <CAKvpyk3i6U46-9_63CsbpmaJqOYSWcrHjFSo-BZELLriWqkRMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Sathya Perla <sathya.perla@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbcBZMYn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2016 07:24:43 -0500
In-Reply-To: <CAKvpyk3i6U46-9_63CsbpmaJqOYSWcrHjFSo-BZELLriWqkRMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.2.2016 12:36, Sathya Perla wrote:
> On Fri, Feb 26, 2016 at 2:16 PM, Ivan Vecera <ivecera@redhat.com> wrote:
>> The FILTMGMT privilege is necessary on BE3 chip to manipulare filters
>> like MC, UC list management, VLAN filter, promisc mode... This privilege
>> is dropped for VFs when transparrent tagging is enabled on them. This
>> prevents to make interface up for such VF because be_enable_if_filters()
>> called from be_open() fails thus be_open() also fails.
>>
>> Cc: Sathya Perla <sathya.perla@broadcom.com>
>> Cc: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>> ---
>>   drivers/net/ethernet/emulex/benet/be_main.c | 11 +++++++----
>>   1 file changed, 7 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
>> index f99de36..2e176f6 100644
>> --- a/drivers/net/ethernet/emulex/benet/be_main.c
>> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
>> @@ -3430,7 +3430,8 @@ static int be_close(struct net_device *netdev)
>>          if (!(adapter->flags & BE_FLAGS_SETUP_DONE))
>>                  return 0;
>>
>> -       be_disable_if_filters(adapter);
>> +       if (!(BEx_chip(adapter) && be_pvid_tagging_enabled(adapter)))
>> +               be_disable_if_filters(adapter);
>>
>>          if (adapter->flags & BE_FLAGS_NAPI_ENABLED) {
>>                  for_all_evt_queues(adapter, eqo, i) {
>> @@ -3571,9 +3572,11 @@ static int be_open(struct net_device *netdev)
>>          if (status)
>>                  goto err;
>>
>> -       status = be_enable_if_filters(adapter);
>> -       if (status)
>> -               goto err;
>> +       if (!(BEx_chip(adapter) && be_pvid_tagging_enabled(adapter))) {
>> +               status = be_enable_if_filters(adapter);
>> +               if (status)
>> +                       goto err;
>
> Ivan, in the be_enable_if_filters() routine the VF tries to enable the
> basic filtering flags (not promisc mode etc) via the RX_FILTER cmd,
> for which the VFs shouldn't need any FILTMGMT privileges. I also don't
> expect be_cmd_pmac_add() to fail as the PF would have already
> provisioned the mac-addr for the VF.
> We should be able to reproduce this first thing Monday morning and see
> what's wrong. Also, as the privilege rules are same across all chips,
> any fix must be applicable for all chips that be2net supports.
Hi Sathya,
if the transparent VLAN tagging is enabled then be_enable_if_filters() 
will fail and be_open() will also fail. This happens only on BE3 not on 
Lancer as this does not support SR-IOV. I don't see any problem on Skyhawk.

Log from the guest after 'ip link set ... up':

[root@bootp-73-131-183 ~]# dmesg | tail -n 20
pci 0000:00:07.0: no hotplug settings from platform
be2net 0000:00:07.0: be2net version is 10.6.0.3r
be2net 0000:00:07.0: enabling device (0040 -> 0042)
be2net 0000:00:07.0: setting latency timer to 64
be2net 0000:00:07.0: FW config: function_mode=0x14003, function_caps=0x4
be2net 0000:00:07.0: VF is not privileged to issue opcode 125-1
be2net 0000:00:07.0: Max: txqs 1, rxqs 1, rss 0, eqs 1, vfs 0
be2net 0000:00:07.0: Max: uc-macs 2, mc-macs 64, vlans 64
   alloc irq_desc for 29 on node -1
   alloc kstat_irqs on node -1
be2net 0000:00:07.0: irq 29 for MSI/MSI-X
be2net 0000:00:07.0: enabled 1 MSI-x vector(s) for NIC
be2net 0000:00:07.0: created 1 TX queue(s)
be2net 0000:00:07.0: created 1 RX queue(s)
be2net 0000:00:07.0: LPVID: 3
be2net 0000:00:07.0: FW version is 10.4.255.25
be2net 0000:00:07.0: HW Flow control - TX:1 RX:1
be2net 0000:00:07.0: Emulex OneConnect(be3): VF  port 0
be2net 0000:00:07.0: VF is not privileged to issue opcode 34-1
be2net 0000:00:07.0: VF is not privileged to issue opcode 60-1

The be_open() calls be_enable_if_filters() -> be_cmd_rx_filter(). 
Command with opcode 34 alias NTWK_RX_FILTER fails thus be_open() also 
fails and be_close() is called as cleaning-up action. The be_close() 
calls then be_disable_if_filters() that calls be_cmd_pmac_del() (opcode 
60). This also fails.

As I has written above under Skyhawk this does not happen... so I has 
created BE3 specific patch.

Ivan
