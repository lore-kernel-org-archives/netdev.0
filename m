From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: convert /proc/net/ip6_flowlabel to seq_file
Date: Tue, 01 Jul 2003 00:12:12 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030701.001212.27447753.yoshfuji@linux-ipv6.org>
References: <20030630.230115.84925092.yoshfuji@linux-ipv6.org>
	<Mutt.LNX.4.44.0307010048540.24506-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0307010048540.24506-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Mutt.LNX.4.44.0307010048540.24506-100000@excalibur.intercode.com.au> (at Tue, 1 Jul 2003 00:49:52 +1000 (EST)), James Morris <jmorris@intercode.com.au> says:

> On Mon, 30 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> 
> > In article <20030629.015723.75141662.yoshfuji@linux-ipv6.org> (at Sun, 29 Jun 2003 01:57:23 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> > 
> > > This converts /proc/net/ip6_flowlabel to seq_file{}.
> > > Thanks.
> > 
> > Oops, this was buggy.  Here's fixed one...
> > 
> 
> This has already been pushed to Dave's tree.  Could you please generate a 
> diff against bk://kernel.bkbits.net/jmorris/net-2.5?

Here it is.

===== net/ipv6/ip6_flowlabel.c 1.3 vs edited =====
--- 1.3/net/ipv6/ip6_flowlabel.c	Sun Jun 29 19:39:57 2003
+++ edited/net/ipv6/ip6_flowlabel.c	Tue Jul  1 00:00:57 2003
@@ -657,7 +657,25 @@
 
 static int ip6fl_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open(file, &ip6fl_seq_ops);
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct ip6fl_iter_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &ip6fl_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
 
 static struct file_operations ip6fl_seq_fops = {
@@ -665,7 +683,7 @@
 	.open		=	ip6fl_seq_open,
 	.read		=	seq_read,
 	.llseek		=	seq_lseek,
-	.release	=	seq_release,
+	.release	=	seq_release_private,
 };
 #endif
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
