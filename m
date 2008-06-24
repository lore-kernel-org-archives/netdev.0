From: "Subrata Modak" <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] CONNECTOR: add a proc entry to list connectors
Date: Tue, 24 Jun 2008 15:30:22 +0530
Message-ID: <bb33bcf20806240300h44b7805bk8673fd53dd5c021f@mail.gmail.com>
References: <4860B279.9070105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1998590854=="
Cc: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Li Zefan" <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <4860B279.9070105-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============1998590854==
Content-Type: multipart/alternative;
	boundary="----=_Part_589_25102481.1214301622175"

------=_Part_589_25102481.1214301622175
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Li,

I hope we are also facing the same problem for executing the Process Event
Connector test cases patch in LTP. If this works out, so will our test cases
patch.

Regards--
Subrata

On Tue, Jun 24, 2008 at 2:08 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:

> I got a problem when I wanted to check if the kernel supports process
> event connector, and It seems there's no way to do this check.
>
> At best I can check if the kernel supports connector or not, by looking
> into /proc/net/netlink, or maybe checking the return value of bind() to
> see if it's ENOENT.
>
> So it would be useful to add /proc/net/connector to list all supported
> connectors:
>  # cat /proc/net/connector
>  Name            ID
>  connector       4294967295:4294967295
>  cn_proc         1:1
>  w1              3:1
>
> Changelog:
> - fix memory leak: s/seq_release/single_release
> - use spin_lock_bh instead of spin_lock_irqsave
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Acked-by: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
> ---
>  drivers/connector/connector.c |   40
> ++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 40 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
> index 85e2ba7..bf48300 100644
> --- a/drivers/connector/connector.c
> +++ b/drivers/connector/connector.c
> @@ -27,6 +27,8 @@
>  #include <linux/moduleparam.h>
>  #include <linux/connector.h>
>  #include <linux/mutex.h>
> +#include <linux/proc_fs.h>
> +#include <linux/spinlock.h>
>
>  #include <net/sock.h>
>
> @@ -403,6 +405,40 @@ static void cn_callback(void *data)
>        mutex_unlock(&notify_lock);
>  }
>
> +static int cn_proc_show(struct seq_file *m, void *v)
> +{
> +       struct cn_queue_dev *dev = cdev.cbdev;
> +       struct cn_callback_entry *cbq;
> +
> +       seq_printf(m, "Name            ID\n");
> +
> +       spin_lock_bh(&dev->queue_lock);
> +
> +       list_for_each_entry(cbq, &dev->queue_list, callback_entry) {
> +               seq_printf(m, "%-15s %u:%u\n",
> +                          cbq->id.name,
> +                          cbq->id.id.idx,
> +                          cbq->id.id.val);
> +       }
> +
> +       spin_unlock_bh(&dev->queue_lock);
> +
> +       return 0;
> +}
> +
> +static int cn_proc_open(struct inode *inode, struct file *file)
> +{
> +       return single_open(file, cn_proc_show, NULL);
> +}
> +
> +static const struct file_operations cn_file_ops = {
> +       .owner   = THIS_MODULE,
> +       .open    = cn_proc_open,
> +       .read    = seq_read,
> +       .llseek  = seq_lseek,
> +       .release = single_release
> +};
> +
>  static int __devinit cn_init(void)
>  {
>        struct cn_dev *dev = &cdev;
> @@ -434,6 +470,8 @@ static int __devinit cn_init(void)
>                return -EINVAL;
>        }
>
> +       proc_net_fops_create(&init_net, "connector", S_IRUGO,
> &cn_file_ops);
> +
>        return 0;
>  }
>
> @@ -443,6 +481,8 @@ static void __devexit cn_fini(void)
>
>        cn_already_initialized = 0;
>
> +       proc_net_remove(&init_net, "connector");
> +
>        cn_del_callback(&dev->id);
>        cn_queue_free_dev(dev->cbdev);
>        netlink_kernel_release(dev->nls);
> --
> 1.5.4.rc3
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Regards & Thanks--
Subrata

------=_Part_589_25102481.1214301622175
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Li,<br><br>I hope we are also facing the same problem for executing the Process Event Connector test cases patch in LTP. If this works out, so will our test cases patch.<br><br>Regards--<br>Subrata<br><br><div class="gmail_quote">
On Tue, Jun 24, 2008 at 2:08 PM, Li Zefan &lt;<a href="mailto:lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org">lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org</a>&gt; wrote:<br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
I got a problem when I wanted to check if the kernel supports process<br>
event connector, and It seems there&#39;s no way to do this check.<br>
<br>
At best I can check if the kernel supports connector or not, by looking<br>
into /proc/net/netlink, or maybe checking the return value of bind() to<br>
see if it&#39;s ENOENT.<br>
<br>
So it would be useful to add /proc/net/connector to list all supported<br>
connectors:<br>
&nbsp;# cat /proc/net/connector<br>
&nbsp;Name &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ID<br>
&nbsp;connector &nbsp; &nbsp; &nbsp; 4294967295:4294967295<br>
&nbsp;cn_proc &nbsp; &nbsp; &nbsp; &nbsp; 1:1<br>
&nbsp;w1 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;3:1<br>
<br>
Changelog:<br>
- fix memory leak: s/seq_release/single_release<br>
- use spin_lock_bh instead of spin_lock_irqsave<br>
<br>
Signed-off-by: Li Zefan &lt;<a href="mailto:lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org">lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org</a>&gt;<br>
Acked-by: Evgeniy Polyakov &lt;<a href="mailto:johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org">johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org</a>&gt;<br>
---<br>
&nbsp;drivers/connector/connector.c | &nbsp; 40 ++++++++++++++++++++++++++++++++++++++++<br>
&nbsp;1 files changed, 40 insertions(+), 0 deletions(-)<br>
<br>
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c<br>
index 85e2ba7..bf48300 100644<br>
--- a/drivers/connector/connector.c<br>
+++ b/drivers/connector/connector.c<br>
@@ -27,6 +27,8 @@<br>
&nbsp;#include &lt;linux/moduleparam.h&gt;<br>
&nbsp;#include &lt;linux/connector.h&gt;<br>
&nbsp;#include &lt;linux/mutex.h&gt;<br>
+#include &lt;linux/proc_fs.h&gt;<br>
+#include &lt;linux/spinlock.h&gt;<br>
<br>
&nbsp;#include &lt;net/sock.h&gt;<br>
<br>
@@ -403,6 +405,40 @@ static void cn_callback(void *data)<br>
 &nbsp; &nbsp; &nbsp; &nbsp;mutex_unlock(&amp;notify_lock);<br>
&nbsp;}<br>
<br>
+static int cn_proc_show(struct seq_file *m, void *v)<br>
+{<br>
+ &nbsp; &nbsp; &nbsp; struct cn_queue_dev *dev = cdev.cbdev;<br>
+ &nbsp; &nbsp; &nbsp; struct cn_callback_entry *cbq;<br>
+<br>
+ &nbsp; &nbsp; &nbsp; seq_printf(m, &quot;Name &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ID\n&quot;);<br>
+<br>
+ &nbsp; &nbsp; &nbsp; spin_lock_bh(&amp;dev-&gt;queue_lock);<br>
+<br>
+ &nbsp; &nbsp; &nbsp; list_for_each_entry(cbq, &amp;dev-&gt;queue_list, callback_entry) {<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; seq_printf(m, &quot;%-15s %u:%u\n&quot;,<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;cbq-&gt;<a href="http://id.name" target="_blank">id.name</a>,<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;cbq-&gt;id.id.idx,<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;cbq-&gt;id.id.val);<br>
+ &nbsp; &nbsp; &nbsp; }<br>
+<br>
+ &nbsp; &nbsp; &nbsp; spin_unlock_bh(&amp;dev-&gt;queue_lock);<br>
+<br>
+ &nbsp; &nbsp; &nbsp; return 0;<br>
+}<br>
+<br>
+static int cn_proc_open(struct inode *inode, struct file *file)<br>
+{<br>
+ &nbsp; &nbsp; &nbsp; return single_open(file, cn_proc_show, NULL);<br>
+}<br>
+<br>
+static const struct file_operations cn_file_ops = {<br>
+ &nbsp; &nbsp; &nbsp; .owner &nbsp; = THIS_MODULE,<br>
+ &nbsp; &nbsp; &nbsp; .open &nbsp; &nbsp;= cn_proc_open,<br>
+ &nbsp; &nbsp; &nbsp; .read &nbsp; &nbsp;= seq_read,<br>
+ &nbsp; &nbsp; &nbsp; .llseek &nbsp;= seq_lseek,<br>
+ &nbsp; &nbsp; &nbsp; .release = single_release<br>
+};<br>
+<br>
&nbsp;static int __devinit cn_init(void)<br>
&nbsp;{<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct cn_dev *dev = &amp;cdev;<br>
@@ -434,6 +470,8 @@ static int __devinit cn_init(void)<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return -EINVAL;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
<br>
+ &nbsp; &nbsp; &nbsp; proc_net_fops_create(&amp;init_net, &quot;connector&quot;, S_IRUGO, &amp;cn_file_ops);<br>
+<br>
 &nbsp; &nbsp; &nbsp; &nbsp;return 0;<br>
&nbsp;}<br>
<br>
@@ -443,6 +481,8 @@ static void __devexit cn_fini(void)<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;cn_already_initialized = 0;<br>
<br>
+ &nbsp; &nbsp; &nbsp; proc_net_remove(&amp;init_net, &quot;connector&quot;);<br>
+<br>
 &nbsp; &nbsp; &nbsp; &nbsp;cn_del_callback(&amp;dev-&gt;id);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;cn_queue_free_dev(dev-&gt;cbdev);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;netlink_kernel_release(dev-&gt;nls);<br>
--<br>
1.5.4.rc3<br>
<font color="#888888">--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel&quot; in<br>
the body of a message to <a href="mailto:majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a><br>
More majordomo info at &nbsp;<a href="http://vger.kernel.org/majordomo-info.html" target="_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at &nbsp;<a href="http://www.tux.org/lkml/" target="_blank">http://www.tux.org/lkml/</a><br>
</font></blockquote></div><br><br clear="all"><br>-- <br>Regards &amp; Thanks--<br>Subrata

------=_Part_589_25102481.1214301622175--


--===============1998590854==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============1998590854==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ltp-list mailing list
Ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/ltp-list

--===============1998590854==--
