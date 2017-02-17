From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 06/14] ixgbe: Update driver to make use of DMA
 attributes in Rx path
Date: Fri, 17 Feb 2017 08:20:31 -0800
Message-ID: <CAKgT0UffTh8RJZJ=s5TjuO23vo-rLdy4K3nZk_pBf4StaC4npQ@mail.gmail.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
 <20170216125041.46668-7-jeffrey.t.kirsher@intel.com> <F95AC9340317A84688A5F0DF0246F3F201EEFEC2@szxemi502-mbx.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36747 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934159AbdBQQUc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 11:20:32 -0500
Received: by mail-it0-f67.google.com with SMTP id g67so3623558itb.3
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 08:20:32 -0800 (PST)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F201EEFEC2@szxemi502-mbx.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 11:27 PM, maowenan <maowenan@huawei.com> wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Jeff Kirsher
>> Sent: Thursday, February 16, 2017 8:51 PM
>> To: davem@davemloft.net
>> Cc: Alexander Duyck; netdev@vger.kernel.org; nhorman@redhat.com;
>> sassmann@redhat.com; jogreene@redhat.com; Jeff Kirsher
>> Subject: [net-next 06/14] ixgbe: Update driver to make use of DMA attributes in
>> Rx path
>>
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This patch adds support for DMA_ATTR_SKIP_CPU_SYNC and
>> DMA_ATTR_WEAK_ORDERING.  By enabling both of these for the Rx path we
>> are able to see performance improvements on architectures that implement
>> either one due to the fact that page mapping and unmapping only has to sync
>> what is actually being used instead of the entire buffer.  In addition by
>> enabling the weak ordering attribute enables a performance improvement for
>> architectures that can associate a memory ordering with a DMA buffer such as
>> Sparc.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |  3 ++
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 56
>> ++++++++++++++++++---------
>>  2 files changed, 40 insertions(+), 19 deletions(-)

<snip>

>
> Hi Alex,
> Is this patch available for arm64? I remember that it needs IOMMU support, right?

I assume you are talking about the DMA_ATTR_WEAK_ORDERING DMA
attribute, and no, it is not available for arm64 last I knew.  It is
related to IOMMU specific attributes available on some SPARC and
PowerPC Cell architectures.

The bit that provides any additional througput on arm related to these
patches is the fact that we sync only the size of the buffer received
now instead of the entire buffer, and that we are only syncing the
region that will be written to by the device when we perform the sync
for the device.  On architectures with non-trivial sync operations
restricting the size to only what is needed should result in a nice
bump up in performance.

- Alex
