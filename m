From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Really fix registering hci with duplicate
 name
Date: Sun, 27 May 2012 09:10:30 +0200
Message-ID: <1338102630.15105.112.camel@aeonflux>
References: <1338060231-31108-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1338060231-31108-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

> Commit fc50744 ("Bluetooth: Fix registering hci with duplicate name") didn't
> fully fix the duplicate naming issue with devices, and duplicate device names
> could still be created:
> 
> [  142.484097] device: 'hci1': device_add
> [...]
> [  150.545263] device: 'hci1': device_add
> [  150.550128] kobject: 'hci1' (ffff880014cc4e58): kobject_add_internal: parent: 'bluetooth', set: 'devices'
> [  150.558979] ------------[ cut here ]------------
> [  150.561438] WARNING: at fs/sysfs/dir.c:529 sysfs_add_one+0xb0/0xd0()
> [  150.572974] Hardware name: Bochs
> [  150.580502] sysfs: cannot create duplicate filename '/devices/virtual/bluetooth/hci1'
> [  150.584444] Pid: 7563, comm: trinity-child1 Tainted: G        W    3.4.0-next-20120524-sasha #296
> [...]
> 
> Instead of the weird logic and the attempt at keeping the device list sorted,
> just use an IDA.
> 
> Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  net/bluetooth/hci_core.c |   30 ++++++++++++++++--------------
>  1 files changed, 16 insertions(+), 14 deletions(-)
> 
> diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
> index 9c586fb..eca6dd1 100644
> --- a/net/bluetooth/hci_core.c
> +++ b/net/bluetooth/hci_core.c
> @@ -26,6 +26,7 @@
>  /* Bluetooth HCI core. */
>  
>  #include <linux/export.h>
> +#include <linux/idr.h>
>  
>  #include <linux/rfkill.h>
>  
> @@ -46,6 +47,9 @@ DEFINE_RWLOCK(hci_dev_list_lock);
>  LIST_HEAD(hci_cb_list);
>  DEFINE_RWLOCK(hci_cb_list_lock);
>  
> +/* HCI ID Numbering */
> +static DEFINE_IDA(hci_index_ida);
> +
>  /* ---- HCI notifications ---- */
>  
>  static void hci_notify(struct hci_dev *hdev, int event)
> @@ -1689,7 +1693,6 @@ EXPORT_SYMBOL(hci_free_dev);
>  /* Register HCI device */
>  int hci_register_dev(struct hci_dev *hdev)
>  {
> -	struct list_head *head, *p;
>  	int id, error;
>  
>  	if (!hdev->open || !hdev->close)
> @@ -1701,25 +1704,19 @@ int hci_register_dev(struct hci_dev *hdev)
>  	 * so the index can be used as the AMP controller ID.
>  	 */
>  	id = (hdev->dev_type == HCI_BREDR) ? 0 : 1;
> -	head = &hci_dev_list;
>  
> -	/* Find first available device id */
> -	list_for_each(p, &hci_dev_list) {
> -		int nid = list_entry(p, struct hci_dev, list)->id;
> -		if (nid > id)
> -			break;
> -		if (nid == id)
> -			id++;
> -		head = p;
> -	}
> +	error = ida_simple_get(&hci_index_ida, id, 0, GFP_KERNEL);
> +	if (error < 0)
> +		return error;
>  
> +	id = error;

I do not really like this "error" thing here.

Why not something simple like this:

	switch (hdev->dev_type) {
	case HCI_BREDR:
		id = ida_simple_get(&hci_index_ida, 0, 0, GFP_KERNEL);
		break;
	case HCI_AMP:
		id = ida_simple_get(&hci_index_idx, 1, 0, GFP_KERNEL);
		break;
	default:
		return -EINVAL;
	}

	if (id < 0)
		return id;

It would have the side effect to also check for valid dev_type at the
same time.

Or just just an extra variable start_id to avoid the "error" naming for
what is expected to be a positive result in almost all cases.

>  	sprintf(hdev->name, "hci%d", id);
>  	hdev->id = id;
>  
>  	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
>  
> -	list_add(&hdev->list, head);
> -
> +	write_lock(&hci_dev_list_lock);
> +	list_add(&hdev->list, &hci_dev_list);
>  	write_unlock(&hci_dev_list_lock);
>  
>  	hdev->workqueue = alloc_workqueue(hdev->name, WQ_HIGHPRI | WQ_UNBOUND |
> @@ -1755,6 +1752,7 @@ int hci_register_dev(struct hci_dev *hdev)
>  err_wqueue:
>  	destroy_workqueue(hdev->workqueue);
>  err:
> +	ida_simple_remove(&hci_index_ida, hdev->id);
>  	write_lock(&hci_dev_list_lock);
>  	list_del(&hdev->list);
>  	write_unlock(&hci_dev_list_lock);
> @@ -1766,12 +1764,14 @@ EXPORT_SYMBOL(hci_register_dev);
>  /* Unregister HCI device */
>  void hci_unregister_dev(struct hci_dev *hdev)
>  {
> -	int i;
> +	int i, id;
>  
>  	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
>  
>  	set_bit(HCI_UNREGISTER, &hdev->dev_flags);
>  
> +	id = hdev->id;
> +
>  	write_lock(&hci_dev_list_lock);
>  	list_del(&hdev->list);
>  	write_unlock(&hci_dev_list_lock);
> @@ -1812,6 +1812,8 @@ void hci_unregister_dev(struct hci_dev *hdev)
>  	hci_dev_unlock(hdev);
>  
>  	hci_dev_put(hdev);
> +
> +	ida_simple_remove(&hci_index_ida, id);
>  }
>  EXPORT_SYMBOL(hci_unregister_dev);
>  

Regards

Marcel
