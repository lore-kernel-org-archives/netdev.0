From: devik <devik@cdi.cz>
Subject: Re: Fw: hfsc and huge set of rules
Date: Fri, 30 Jul 2004 17:54:39 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0407301752250.1421-100000@devix>
References: <410A2449.3020701@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <hadi@cyberus.ca>,
        <netdev@oss.sgi.com>, <tomasz.paszkowski@e-wro.pl>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410A2449.3020701@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Also IIRC class lookup is done before each remove. With
hashing size a few tens of buckets the complexity
starts to be very near to O(n^2).

devik

On Fri, 30 Jul 2004, Patrick McHardy wrote:

> David S. Miller wrote:
> > Looks like qdisc destruction has some expensive algorithms.
> > Any quick ideas about the root culprit at least in the hfsc
> > case?  He says htb does it too.
>
> hfsc_destroy_qdisc takes O(n) time wrt. the number of classes,
> but 5-6 seconds is still long. If all these classes contain inner
> qdiscs other than the default, I guess removing the classes from
> dev->qdisc_list in qdisc_destroy takes up most of the time, with
> n O(n) operations. The __qdisc_destroy rcu callback also calls
> reset before destroy, I don't know any qdisc where this is really
> neccessary. Without inner qdiscs, I need to see the script first to
> judge what's going wrong. Tomasz ?
>
> BTW: The lockless loopback patch broke qdisc_destroy in multiple ways.
> The rcu callback doesn't do any locking, to add locking all
> read/write_lock(qdisc_tree_lock) need to be changed to
> read/write_lock_bh because the callback is called from a tasklet,
> until now all changes to the tree structure were made in
> process-context. Additionally it invalidates the assumption made by
> dev_shutdown that qdisc_destroy will destroy all qdiscs and clear
> dev->qdisc_list immediately. Since qdisc->dev is not refcounted
> netdev_wait_allrefs won't notice when the rcu callback hasn't destroyed
> all qdiscs yet and free the device, but qdisc_destroy called from
> ops->destroy called from the callback will still access the memory.
> Patch coming up soon.
>
> Regards
> Patrick
>
> > Begin forwarded message:
> >
> > Date: Tue, 27 Jul 2004 11:47:02 +0200
> > From: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
> > To: linux-kernel@vger.kernel.org
> > Subject: hfsc and huge set of rules
> >
> >
> > Hello,
> >
> > I'am running hfsc qdisc with huge set of rules loaded.
> >
> > root@hades:/home/system/scr/etc/hfsc_rebuild# cat tc.batch | grep hfsc | wc -l
> >   27884
> >
> >
> > Always when I delete the root qdisc (qdisc del dev eth0 root)
> > the machine stop responding for about 5-6 seconds. As I think it's due the
> > hfsc_destory_qdisc is executed in main kernel thread. Similar problem is
> > present also in htb scheduler.
> >
> > Is there any quick solution to solve this problem ?
> >
>
>
>
