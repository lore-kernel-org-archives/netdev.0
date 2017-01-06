From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCHv1 5/7] TAP: Extending tap device create/destroy APIs
Date: Sat, 7 Jan 2017 01:20:48 +0200
Message-ID: <CAHp75VcEquDVRA4yNSh4pxczc60=+fdFkeG4Cji1patZYUk6xw@mail.gmail.com>
References: <1483742009-19184-1-git-send-email-sainath.grandhi@intel.com> <1483742009-19184-6-git-send-email-sainath.grandhi@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, mahesh@bandewar.net,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sainath Grandhi <sainath.grandhi@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36073 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964827AbdAFXUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 18:20:49 -0500
In-Reply-To: <1483742009-19184-6-git-send-email-sainath.grandhi@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 7, 2017 at 12:33 AM, Sainath Grandhi
<sainath.grandhi@intel.com> wrote:
> Extending tap APIs get/free_minor and create/destroy_cdev to handle more than one
> type of virtual interface.
>
> Signed-off-by: Sainath Grandhi <sainath.grandhi@intel.com>
> Tested-by: Sainath Grandhi <sainath.grandhi@intel.com>

Usually it implies that commiter has tested the stuff.

> --- a/drivers/net/tap.c
> +++ b/drivers/net/tap.c
> @@ -99,12 +99,16 @@ static struct proto tap_proto = {
>  };
>
>  #define TAP_NUM_DEVS (1U << MINORBITS)

> +
> +LIST_HEAD(major_list);
> +

static ?

> -int tap_get_minor(struct tap_dev *tap)
> +int tap_get_minor(dev_t major, struct tap_dev *tap)
>  {
>         int retval = -ENOMEM;
> +       struct major_info *tap_major, *tmp;
> +       bool found = false;
>
> -       mutex_lock(&macvtap_major.minor_lock);
> -       retval = idr_alloc(&macvtap_major.minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);

> +       list_for_each_entry_safe(tap_major, tmp, &major_list, next) {
> +               if (tap_major->major == MAJOR(major)) {
> +                       found = true;
> +                       break;
> +               }
> +       }
> +
> +       if (!found)
> +               return -EINVAL;

This is candidate to be a separate helper function. See also below.


> -void tap_free_minor(struct tap_dev *tap)
> +void tap_free_minor(dev_t major, struct tap_dev *tap)
>  {
> -       mutex_lock(&macvtap_major.minor_lock);
> +       struct major_info *tap_major, *tmp;

> +       bool found = false;
> +
> +       list_for_each_entry_safe(tap_major, tmp, &major_list, next) {
> +               if (tap_major->major == MAJOR(major)) {
> +                       found = true;
> +                       break;
> +               }
> +       }
> +
> +       if (!found)
> +               return;

Here is quite the same code (as above).

> -static struct tap_dev *dev_get_by_tap_minor(int minor)
> +static struct tap_dev *dev_get_by_tap_file(int major, int minor)
>  {
>         struct net_device *dev = NULL;
>         struct tap_dev *tap;
> +       struct major_info *tap_major, *tmp;
> +       bool found = false;
>
> -       mutex_lock(&macvtap_major.minor_lock);
> -       tap = idr_find(&macvtap_major.minor_idr, minor);

> +       list_for_each_entry_safe(tap_major, tmp, &major_list, next) {
> +               if (tap_major->major == major) {
> +                       found = true;
> +                       break;
> +               }
> +       }
> +
> +       if (!found)
> +               return NULL;

And here.

> +static int tap_list_add(dev_t major, const char *device_name)
> +{

> +       int err = 0;
> +       struct major_info *tap_major;

Perhaps
+       struct major_info *tap_major;
+       int err = 0;

> +
> +       tap_major = kzalloc(sizeof(*tap_major), GFP_ATOMIC);
> +
> +       tap_major->major = MAJOR(major);
> +
> +       idr_init(&tap_major->minor_idr);
> +       mutex_init(&tap_major->minor_lock);
> +
> +       tap_major->device_name = device_name;
> +
> +       list_add_tail(&tap_major->next, &major_list);
> +       return err;


> +       err = tap_list_add(*tap_major, device_name);
>
>         return err;

return tap_list_add();

>  void tap_destroy_cdev(dev_t major, struct cdev *tap_cdev)
>  {
> +       struct major_info *tap_major, *tmp;
> +       bool found = false;
> +
> +       list_for_each_entry_safe(tap_major, tmp, &major_list, next) {
> +               if (tap_major->major == MAJOR(major)) {
> +                       found = true;
> +                       break;
> +               }
> +       }
> +
> +       if (!found)
> +               return;

And here.

-- 
With Best Regards,
Andy Shevchenko
