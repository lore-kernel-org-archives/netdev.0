From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: Re: [PATCH for bnxt_re V4 03/21] RDMA/bnxt_re: register with the NIC driver
Date: Fri, 10 Feb 2017 17:11:00 +0530
Message-ID: <CA+sbYW2iajTVnHUVhdch+y-TjexcKpwFCCS0bx+iUc=OA3U3YA@mail.gmail.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
 <1482320530-5344-4-git-send-email-selvin.xavier@broadcom.com> <1486412780.86943.5.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-rdma@vger.kernel.org,
        Linux Netdev List <netdev@vger.kernel.org>,
        Michael Chan <michael.chan@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36693 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752030AbdBJLtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 06:49:23 -0500
Received: by mail-qk0-f173.google.com with SMTP id 11so35770402qkl.3
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 03:48:25 -0800 (PST)
In-Reply-To: <1486412780.86943.5.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 1:56 AM, Doug Ledford <dledford@redhat.com> wrote:
>> +static void bnxt_re_dev_remove(struct bnxt_re_dev *rdev)
>> +{
>> +       int i = BNXT_RE_REF_WAIT_COUNT;
>> +
>> +       /* Wait for rdev refcount to come down */
>> +       while ((atomic_read(&rdev->ref_count) > 1) && i--)
>> +               msleep(100);
>> +
>> +       if (atomic_read(&rdev->ref_count) > 1)
>> +               dev_err(rdev_to_dev(rdev),
>> +                       "Failed waiting for ref count to deplete %d",
>> +                       atomic_read(&rdev->ref_count));
>> +
>> +       atomic_set(&rdev->ref_count, 0);
>> +       dev_put(rdev->netdev);
>> +       rdev->netdev = NULL;
>> +
>> +       mutex_lock(&bnxt_re_dev_lock);
>> +       list_del_rcu(&rdev->list);
>> +       mutex_unlock(&bnxt_re_dev_lock);
>> +
>> +       synchronize_rcu();
>> +       flush_workqueue(bnxt_re_wq);
>> +
>> +       ib_dealloc_device(&rdev->ibdev);
>> +       /* rdev is gone */
>> +}
>
> This looks bad.  Either your ref counting is right, and your ref count
> should go to 1, or you have an issue that won't be helped by forcibly
> removing the device.  In its current form, this looks like an oopser
> waiting to happen.
>
> If you know your ref counting is right, then simply wait until it goes
> to 1, don't have this bailout logic.  If you truly need to bailout for
> some reason, then you need to not free things.  Better to shutdown then
> leak and live than release and have a use after free data corrupter.

Thanks for your commet.
I reviewed the usage of ref_count again and it is not really required
in this patch series.
It is being incremented and decremented from the netdev notifier and
will be always 1
in bnxt_re_dev_remove. bnxt_re_dev_remove is also invoked from netdev
notifier, so
no need to wait in this function.  So, I have removed ref_count
variable and cleaned up
this function in the v5 patch set.

Thanks,
Selvin
