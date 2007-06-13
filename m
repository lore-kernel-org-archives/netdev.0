From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [RFC][PATCH -mm take5 3/7] add interface for netconsole using sysfs
Date: Wed, 13 Jun 2007 21:19:58 +0530
Message-ID: <a781481a0706130849u2373983eyeab365a8bc90a4dd@mail.gmail.com>
References: <466FC455.5060001@bx.jp.nec.com> <466FC6BB.4040105@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.237]:60857 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757968AbXFMPt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 11:49:59 -0400
Received: by wr-out-0506.google.com with SMTP id 76so204653wra
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 08:49:58 -0700 (PDT)
In-Reply-To: <466FC6BB.4040105@bx.jp.nec.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 6/13/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> From: Keiichi KII <k-keiichi@bx.jp.nec.com>
>
> This patch contains the following changes.
>
> create a sysfs entry for netconsole in /sys/class/misc.
> This entry has elements related to netconsole as follows.
> You can change configuration of netconsole(writable attributes such as IP
> address, port number and so on) and check current configuration of netconsole.
>
> -+- /sys/class/misc/
>  |-+- netconsole/
>    |-+- port1/
>    | |--- id          [r--r--r--]  unique port id
>    | |--- local_ip    [rw-r--r--]  source IP to use, writable
>    | |--- local_mac   [r--r--r--]  source MAC address
>    | |--- local_port  [rw-r--r--]  source port number for UDP packets, writable
>    | |--- remote_ip   [rw-r--r--]  port number for logging agent, writable
>    | |--- remote_mac  [rw-r--r--]  MAC address for logging agent, writable
>    | ---- remote_port [rw-r--r--]  IP address for logging agent, writable
>    |--- port2/
>    |--- port3/

[...]
> +static int miscdev_configured;

Is this really required? We just return with error if misc_register()
fails during module init time itself, so it's not really useful ever, is it?

> +static ssize_t show_target_attr(struct kobject *kobj,
[...]
> +       if (na->show)
> +               return na->show(nt, buffer);
> +       else
> +               return -EIO;

and

> +static ssize_t store_target_attr(struct kobject *kobj,
[...]
> +       if (na->store)
> +               return na->store(nt, buffer, count);
> +       else
> +               return -EIO;

EIO isn't quite appropriate for the above two cases. EPERM?

> +static int setup_target_sysfs(struct netconsole_target *nt)
> +{
> +       kobject_set_name(&nt->obj, "port%d", nt->id);

Ah, I see, so this is where we use the ->id member.

> @@ -192,7 +386,9 @@ static void cleanup_netconsole(void)
>
>         unregister_console(&netconsole);
>         list_for_each_entry_safe(nt, tmp, &target_list, list)
> -               remove_target(nt);
> +               kobject_unregister(&nt->obj);
> +       if (miscdev_configured)
> +               misc_deregister(&netconsole_miscdev);

Yeah, I suspect we can do away with miscdev_configured here.
We reach this code only if it is known to be true.

> +       if (misc_register(&netconsole_miscdev)) {
> +               printk(KERN_ERR
> +                      "netconsole: failed to register misc device for "
> +                      "name = %s, id = %d\n",
> +                      netconsole_miscdev.name, netconsole_miscdev.minor);
> +               return -EIO;
> +       } else
> +               miscdev_configured = 1;
> +

Please prefer:

err = misc_register(...);
if (err)
        ...
        return err;

That way we avoid the weird EIO and maintain the error code
returned by misc_register().

Satyam
