From: Horms <horms@verge.net.au>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Mon, 26 Sep 2005 12:28:08 +0900
Message-ID: <20050926032807.GI18357__22408.787374343$1127708888$gmane$org@verge.net.au>
References: <68559cef050908090657fc2599@mail.gmail.com> <498263350509081605956a771@mail.gmail.com> <68559cef05092207022f1f0df4@mail.gmail.com> <498263350509230815eb08a73@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Dave Miller <davem@davemloft.net>,
        Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Tsang <roger.tsang@gmail.com>, Luca Maranzano <liuk001@gmail.com>,
        "LinuxVirtualServer.org users  mailing list." <lvs-users@LinuxVirtualServer.org>
Content-Disposition: inline
In-Reply-To: <498263350509230815eb08a73@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 23, 2005 at 11:15:31AM -0400, Roger Tsang wrote:
> As I've said before in this thread, you might want to try changing all the
> ssleep() calls to schedule_timeout().
> 
> Roger
> 
> 
> On 9/22/05, Luca Maranzano <liuk001@gmail.com> wrote:
> >
> > Hello all,
> >
> > here again trying to discover the reason ot the CPU hog for
> > ipvs_sync{master,backup}.
> >
> > I've digged in the sources for ip_vs_sync.c and the main differences
> > between kernel 2.6.8 and 2.6.12 is the use of ssleep() instead of
> > schedule_timeout().
> >
> > The oddity I've seen is that in the header of both files, the version
> > is always like this:
> >
> > * Version: $Id: ip_vs_sync.c,v 1.13 2003/06/08 09:31:19 wensong Exp $
> > *
> > * Authors: Wensong Zhang <wensong@linuxvirtualserver.org>
> >
> > Is Wensong still the maintainer for this code?

Yes, although he is kind of quiet.

> > Furthermore, if I make an "rgrep" in the source tree of kernel 2.6.12
> > the function schedule_timeout() is more used than the ssleep() (517
> > occurrencies vs. 43), so why in ip_vs_sync.c there was this change?
> >
> > The other oddity is that Horms reported on this list that on non Xeon
> > CPU the same version of kernel of mine does not present the problem.
> >
> > I'm getting crazy :-)

I've prepared a patch, which reverts the change which was introduced
by Nishanth Aravamudan in February.

I have CCed him, Dave Miller, Wensong Zhang, Julian Anastasov, and the
netdev list for comment. 

Could intererested parties please test the patch.

Thanks

-- 
Horms

Use schedule_timeout() instead of ssleep() in ip_vs_sync daemon,
as the latter seems to cause 100% CPU utilistaion on HT Xeons.

Discussion:
http://archive.linuxvirtualserver.org/html/lvs-users/2005-09/msg00031.html

Reverts:
http://www.kernel.org/git/?p=linux/kernel/git/tglx/history.git;a=commit;h=f8afb60c7537130448cc479d6d8dc9bf4ee06027

Signed-off-by: Horms <horms@verge.net.au>

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -655,7 +655,9 @@ static void sync_master_loop(void)
 		if (stop_master_sync)
 			break;
 
-		ssleep(1);
+		__set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ);
+		__set_current_state(TASK_RUNNING);
 	}
 
 	/* clean up the sync_buff queue */
@@ -712,7 +714,9 @@ static void sync_backup_loop(void)
 		if (stop_backup_sync)
 			break;
 
-		ssleep(1);
+		__set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ);
+		__set_current_state(TASK_RUNNING);
 	}
 
 	/* release the sending multicast socket */
@@ -824,7 +828,9 @@ static int fork_sync_thread(void *startu
 	if ((pid = kernel_thread(sync_thread, startup, 0)) < 0) {
 		IP_VS_ERR("could not create sync_thread due to %d... "
 			  "retrying.\n", pid);
-		ssleep(1);
+		__set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ);
+		__set_current_state(TASK_RUNNING);
 		goto repeat;
 	}
 
@@ -858,7 +864,9 @@ int start_sync_thread(int state, char *m
 	if ((pid = kernel_thread(fork_sync_thread, &startup, 0)) < 0) {
 		IP_VS_ERR("could not create fork_sync_thread due to %d... "
 			  "retrying.\n", pid);
-		ssleep(1);
+		__set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(HZ);
+		__set_current_state(TASK_RUNNING);
 		goto repeat;
 	}
 
