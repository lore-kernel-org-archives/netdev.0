From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH retry] bluetooth : add conn add/del
 workqueues to avoid connection fail
Date: Thu, 31 Jan 2008 18:33:58 -0800 (PST)
Message-ID: <20080131.183358.229943667.davem@davemloft.net>
References: <20080130022354.GA3132@darkstar.te-china.tietoenator.com>
	<20080131130930.GW15220@kernel.dk>
	<20080201012441.GA2924@darkstar.te-china.tietoenator.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	linux-kernel@vger.kernel.org, bluez-devel@lists.sf.net,
	jens.axboe@oracle.com
To: hidave.darkstar@gmail.com
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080201012441.GA2924@darkstar.te-china.tietoenator.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Dave Young <hidave.darkstar@gmail.com>
Date: Fri, 1 Feb 2008 09:24:41 +0800

> On Thu, Jan 31, 2008 at 02:09:30PM +0100, Jens Axboe wrote:
> > On Wed, Jan 30 2008, Dave Young wrote:
> > > 
> > > The bluetooth hci_conn sysfs add/del executed in the default workqueue.
> > > If the del_conn is executed after the new add_conn with same target,
> > > add_conn will failed with warning of "same kobject name".
> > > 
> > > Here add btaddconn & btdelconn workqueues,
> > > flush the btdelconn workqueue in the add_conn function to avoid the issue.
> > > 
> > > Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 
> > > 
> > > ---
> > > diff -upr a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
> > > --- a/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:27.000000000 +0800
> > > +++ b/net/bluetooth/hci_sysfs.c	2008-01-30 10:14:14.000000000 +0800
> > > @@ -12,6 +12,8 @@
> > >  #undef  BT_DBG
> > >  #define BT_DBG(D...)
> > >  #endif
> > > +static struct workqueue_struct *btaddconn;
> > > +static struct workqueue_struct *btdelconn;
> > >  
> > >  static inline char *typetostr(int type)
> > >  {
> > > @@ -279,6 +281,7 @@ static void add_conn(struct work_struct 
> > >  	struct hci_conn *conn = container_of(work, struct hci_conn, work);
> > >  	int i;
> > >  
> > > +	flush_workqueue(btdelconn);
> > >  	if (device_add(&conn->dev) < 0) {
> > >  		BT_ERR("Failed to register connection device");
> > >  		return;
> > > @@ -313,6 +316,7 @@ void hci_conn_add_sysfs(struct hci_conn 
> > >  
> > >  	INIT_WORK(&conn->work, add_conn);
> > >  
> > > +	queue_work(btaddconn, &conn->work);
> > >  	schedule_work(&conn->work);
> > >  }
> > 
> > So you queue &conn->work on both btaddconn and keventd_wq?
> 
> My fault. Thanks for pointing out.
> 
> new patch as following (some fixes according to marcel's style as well)

Your original patch was already in the tree, so I just checked
in the relative changes.

Please don't me do this next time :-)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
