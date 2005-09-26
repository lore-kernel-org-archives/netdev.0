From: Horms <horms@verge.net.au>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Mon, 26 Sep 2005 17:12:32 +0900
Message-ID: <20050926081229.GA23755__13221.9807980166$1127722709$gmane$org@verge.net.au>
References: <68559cef050908090657fc2599@mail.gmail.com> <498263350509081605956a771@mail.gmail.com> <68559cef05092207022f1f0df4@mail.gmail.com> <498263350509230815eb08a73@mail.gmail.com> <20050926032807.GI18357@verge.net.au> <20050926043400.GD5079@us.ibm.com> <20050926080508.GF11027@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>, Roger Tsang <roger.tsang@gmail.com>,
        Luca Maranzano <liuk001@gmail.com>,
        "LinuxVirtualServer.org users  mailing list." <lvs-users@LinuxVirtualServer.org>,
        Dave Miller <davem@davemloft.net>,
        Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
        netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050926080508.GF11027@verge.net.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2005 at 05:05:10PM +0900, Horms wrote:

[snip]

> > > > > Furthermore, if I make an "rgrep" in the source tree of kernel 2.6.12
> > > > > the function schedule_timeout() is more used than the ssleep() (517
> > > > > occurrencies vs. 43), so why in ip_vs_sync.c there was this change?
> > > > >
> > > > > The other oddity is that Horms reported on this list that on non Xeon
> > > > > CPU the same version of kernel of mine does not present the problem.
> > > > >
> > > > > I'm getting crazy :-)
> > > 
> > > I've prepared a patch, which reverts the change which was introduced
> > > by Nishanth Aravamudan in February.
> > 
> > Was the 100% cpu utilization only occurring on Xeon processors?
> 
> That seems to be the only case where were this problem has been
> observed. I don't have such a processor myself, so I haven't actually
> been able to produce the problem locally.
> 
> One reason I posted this issue to netdev was to get some more
> eyes on the problem as it is puzzling to say the least.
> 
> > Care to try to use msleep_interruptible() instead of ssleep(), as
> > opposed to schedule_timeout()?
> 
> I will send a version that does that shortly, Luca, can
> you plase check that too?

Here is that version of the patch. Nishanth, I take it that I do not
need to set TASK_INTERRUPTABLE before calling msleep_interruptible(),
please let me know if I am wrong.

Luca, please test.

-- 
Horms

*UNTESTED*

Use msleep_interruptible() instead of ssleep() in ip_vs_sync daemon,
as the latter seems to cause 100% CPU utilistaion on HT Xeons.

Discussion:
http://archive.linuxvirtualserver.org/html/lvs-users/2005-09/msg00031.html

Reverts:
http://www.kernel.org/git/?p=linux/kernel/git/tglx/history.git;a=commit;h=f8afb60c7537130448cc479d6d8dc9bf4ee06027

Signed-off-by: Horms <horms@verge.net.au>

diff --git a/net/ipv4/ipvs/ip_vs_sync.c b/net/ipv4/ipvs/ip_vs_sync.c
--- a/net/ipv4/ipvs/ip_vs_sync.c
+++ b/net/ipv4/ipvs/ip_vs_sync.c
@@ -655,7 +655,7 @@ static void sync_master_loop(void)
 		if (stop_master_sync)
 			break;
 
-		ssleep(1);
+		msleep_interruptible(1000);
 	}
 
 	/* clean up the sync_buff queue */
@@ -712,7 +712,7 @@ static void sync_backup_loop(void)
 		if (stop_backup_sync)
 			break;
 
-		ssleep(1);
+		msleep_interruptible(1000);
 	}
 
 	/* release the sending multicast socket */
@@ -824,7 +824,7 @@ static int fork_sync_thread(void *startu
 	if ((pid = kernel_thread(sync_thread, startup, 0)) < 0) {
 		IP_VS_ERR("could not create sync_thread due to %d... "
 			  "retrying.\n", pid);
-		ssleep(1);
+		msleep_interruptible(1000);
 		goto repeat;
 	}
 
@@ -858,7 +858,7 @@ int start_sync_thread(int state, char *m
 	if ((pid = kernel_thread(fork_sync_thread, &startup, 0)) < 0) {
 		IP_VS_ERR("could not create fork_sync_thread due to %d... "
 			  "retrying.\n", pid);
-		ssleep(1);
+		msleep_interruptible(1000);
 		goto repeat;
 	}
 
