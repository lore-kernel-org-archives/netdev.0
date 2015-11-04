From: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
Subject: Re: [PATCH net-next] vlan: Invoke driver vlan hooks only if device is present
Date: Wed, 4 Nov 2015 13:31:12 +0530
Message-ID: <CAE37WoMO9JJDY8daYbGkqcM+9Bwcz-+5K0CMknyFJSfHgSJZ7Q@mail.gmail.com>
References: <1446562559-7264-1-git-send-email-padmanabh.ratnakar@avagotech.com>
	<20151103.111633.1800653969325047017.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33830 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732AbbKDIBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 03:01:13 -0500
Received: by oies66 with SMTP id s66so23742522oie.1
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 00:01:12 -0800 (PST)
In-Reply-To: <20151103.111633.1800653969325047017.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Tue, Nov 3, 2015 at 9:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
> Date: Tue,  3 Nov 2015 20:25:59 +0530
>
>> NIC drivers mark device as detached during error recovery.
>> It expects no manangement hooks to be invoked in this state.
>> Invoke driver vlan hooks only if device is present.
>>
>> Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
>
> I don't like this.
>
> This approach to solving the issue just peppers checks randomly around
> the kernel and the risk for missing cases is very high.  It is also
> not clear to me what exactly specifies that these calls are not valid
> in such states.
>
> Traditionally we've depended upon the driver to make this kind of check
> in it's callback, and that way we don't need to add extra overhead for
> everyone at all of these method invokcation points.
>
> Therefore, I would like to see a less dirty, and less error prone
> approach to solving this bug.

I am trying to figure out the correct place for this check.

Currently for invoking of most managements hooks, kernel follows below pattern -
(ethtool, set mac, set mtu etc..)

rtlnl_lock();
if (!netif_device_present(netdev))
        return -ENODEV;
if (ops->ndo_xxxxx)
         ops->ndo_xxxxx;
rtnl_unlock();

Many drivers((emulex, intel, tg3 etc)) when they are recovering from error like
PCIe error, do the following -

In error_detected routine, before starting recovery -

rtnl_lock();
...
netif_device_detach(netdev);
....
rtnl_unlock();

After error is recovered, driver moves the device to attached state
using netif_device_attach().
Drivers use other methods to quiesce data path hooks.

Management hooks implementation of driver don't check if device is in
error recovery.
They expect that these hooks wont get called if device is marked as not present.

Device present check is missing for vlan addition/deletion.
Be2net driver may have an issue if this hook gets invoked during error recovery.
I thought it may be better if this is also handled like other management hooks.
Please let me know if I am missing anything and what you feel in right
place to put this
check - in kernel or in driver.


Thanks,
Padmanabh
