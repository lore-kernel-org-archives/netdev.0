From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH next-next] ppp: change default for incoming protocol filter to NPMODE_DROP
Date: Fri, 6 Jul 2012 13:28:00 -0400
Message-ID: <20120706172800.GC19462@kvack.org>
References: <20120704013258.GA26225@kvack.org> <20120705.030027.655926012207641451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120705.030027.655926012207641451.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2012 at 03:00:27AM -0700, David Miller wrote:
> As far as I can tell, this has been this way for a very long time.
> 
> Therefore it is the applications responsibility to adjust the filters
> to suit their needs and we really can't make such adjustments to this
> behavior.

Okay.  Clearing all the protocols the kernel may support in the future is a 
bit expensive due to a lack of a way to get the protocols supported -- the 
code would have to walk the entire protocol id space.  How about the 
following addition instead to provide a list of protocols to disable?

		-ben


[PATCH net-next] ppp: add PPPIOCGPROTOS ioctl to get the list of protocols

At present there is no means for a userspace ppp implementation to get a 
list of protocols supported by the kernel.  Add an ioctl, PPPIOCGPROTOS to 
get the protocol list array where [0] is the number of protocols in the 
array.

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 5c05572..daf50aa 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -565,6 +565,20 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 	int __user *p = argp;
 
+	if (cmd == PPPIOCGPROTOS) {
+		if (get_user(val, p))
+			return err;
+		if (val <= 0)
+			return -EINVAL;
+		if (NUM_NP < val)
+			val = NUM_NP;
+		if (put_user(val, p))
+			return err;
+		if (copy_to_user(p + 1, &npindex_to_proto, sizeof(int) * val))
+			return err;
+		return 0;
+	}
+
 	if (!pf)
 		return ppp_unattached_ioctl(current->nsproxy->net_ns,
 					pf, file, cmd, arg);
diff --git a/include/linux/ppp-ioctl.h b/include/linux/ppp-ioctl.h
index 2d9a885..d2cc304 100644
--- a/include/linux/ppp-ioctl.h
+++ b/include/linux/ppp-ioctl.h
@@ -81,6 +81,7 @@ struct pppol2tp_ioc_stats {
  * Ioctl definitions.
  */
 
+#define	PPPIOCGPROTOS	_IOWR('t', 90, int)	/* get protocol list array */
 #define	PPPIOCGFLAGS	_IOR('t', 90, int)	/* get configuration flags */
 #define	PPPIOCSFLAGS	_IOW('t', 89, int)	/* set configuration flags */
 #define	PPPIOCGASYNCMAP	_IOR('t', 88, int)	/* get async map */
