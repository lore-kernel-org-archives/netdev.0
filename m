From: Veaceslav Falico <darkmag@gmail.com>
Subject: Re: [PATCH RFC net] msi: free msi_desc entry only after we've
 released the kobject
Date: Tue, 17 Sep 2013 03:46:33 +0200
Message-ID: <CAE3RKN=1uh03498hWejgY5zVC=p8RfjWY9ESW5TnuaDr=DxcJQ@mail.gmail.com>
References: <1379351396-6458-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:62261 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab3IQBqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:46:54 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so6135829pad.9
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 18:46:53 -0700 (PDT)
In-Reply-To: <1379351396-6458-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 7:09 PM, Veaceslav Falico <vfalico@redhat.com> wrote:
> Currently, we first do kobject_put(&entry->kobj) and the kfree(entry),
> however kobject_put() doesn't guarantee us that it was the last reference
> and that the kobj isn't used currently by someone else, so after we
> kfree(entry) with the struct kobject - other users will begin using the
> freed memory, instead of the actual kobject.
>
> Fix this by using the kobject->release callback, which is called last when
> the kobject is indeed not used and is cleaned up - it's msi_kobj_release(),
> which can do the kfree(entry) safely (kobject_put/cleanup doesn't use the
> kobj itself after ->release() was called, so we're safe).
>
> Also, in case we've failed to create the sysfs directories - just kfree()
> it - cause we don't have the kobjects attached.
>
> CC: Neil Horman <nhorman@tuxdriver.com>
> CC: Russell King <rmk+kernel@arm.linux.org.uk>
> CC: Bjorn Helgaas <bhelgaas@google.com>
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
> ---
>
> Notes:
>     This patch is really an RFC, and I don't know for sure how to correctly
>     fix it, however it seems to work. Sorry if I've done something horribly
>     wrong, it really seems to work ok :).

Sorry, done two things horribly wrong - wrong list and
still a bit buggy patch.

Will send a new version to the appropriate lists :).

>
>     I've hit the bug with the recent CONFIG_DEBUG_KOBJECT_RELEASE - it basically
>     delays the cleanup a bit - so that the chances are a lot higher even for
>     one user to hit it.
>
>     Or, maybe, it will be better to just add an kobject helper
>     kobject_wait_cleanup(), which will return only after it's indeed free? I'm
>     really not sure.
>
>  drivers/pci/msi.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
> index b35f93c..6eabf93 100644
> --- a/drivers/pci/msi.c
> +++ b/drivers/pci/msi.c
> @@ -395,6 +395,7 @@ static void free_msi_irqs(struct pci_dev *dev)
>                         if (list_is_last(&entry->list, &dev->msi_list))
>                                 iounmap(entry->mask_base);
>                 }
> +               list_del(&entry->list);
>
>                 /*
>                  * Its possible that we get into this path
> @@ -405,10 +406,9 @@ static void free_msi_irqs(struct pci_dev *dev)
>                 if (entry->kobj.parent) {
>                         kobject_del(&entry->kobj);
>                         kobject_put(&entry->kobj);
> +               } else {
> +                       kfree(entry);
>                 }
> -
> -               list_del(&entry->list);
> -               kfree(entry);
>         }
>  }
>
> @@ -531,6 +531,7 @@ static void msi_kobj_release(struct kobject *kobj)
>         struct msi_desc *entry = to_msi_desc(kobj);
>
>         pci_dev_put(entry->dev);
> +       kfree(entry);
>  }
>
>  static struct kobj_type msi_irq_ktype = {
> --
> 1.8.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
