From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Sun, 21 Nov 2004 17:27:43 +0100
Message-ID: <200411211727.43320.bdschuym@pandora.be>
References: <20041115122046.1413527e.akpm@osdl.org> <20041115124843.4c3dd72f.akpm@osdl.org> <419C8724.20006@uznam.net.pl>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_/HMoBK1B9Y3ldpH"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?utf-8?q?Micha=C5=82=20Margula?= <alchemyx@uznam.net.pl>,
        Andrew Morton <akpm@osdl.org>
In-Reply-To: <419C8724.20006@uznam.net.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_/HMoBK1B9Y3ldpH
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 18 November 2004 12:27, Micha=C5=82 Margula wrote:
> >Bart De Schuymer <bdschuym@pandora.be> wrote:
> >>>Problem is present in 2.6.8.1 and 2.6.9 kernels. There was no such
> >>> problem on 2.4.26.
> >>
> >>Can you do something similar with iptables rules to see if it's specific
> >> to ebtables (which I doubt)?
>
> Over 50 hours after converting rules from ebtables to iptables and still
> no lockup. Everything is fine and I am sure it will go stable for days
> (as mentioned before lockup with ebtables happens in less than 24 hours).

The only thing I can come up with is that your packets are coming in so fas=
t=20
that the ebtables user context code cannot get the write_lock_bh.
Please apply the attached patch to be sure it hangs on the write_lock_bh, b=
y=20
doing
# cd /usr/src/linux-2.6.9/
# patch -p1 < patch
When your system hangs again, the message "EBTABLES: BEFORE WRITE LOCK"
should be in your syslog, and check that it is not followed by "EBTABLES:=20
AFTER WRITE LOCK".

Is the bridge still forwarding packets while it hangs?

Perhaps try to link all network traffic to one cpu before doing your ebtabl=
es=20
updates...
I strongly doubt there is a deadlock hidden in the ebtables code. Perhaps=20
other people on this list can throw in possibilities...

cheers,
Bart

--Boundary-00=_/HMoBK1B9Y3ldpH
Content-Type: text/x-diff;
  charset="utf-8";
  name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="patch"

--- linux-2.6.9/net/bridge/netfilter/ebtables.c.old	2004-11-21 17:00:49.000000000 +0100
+++ linux-2.6.9/net/bridge/netfilter/ebtables.c	2004-11-21 17:15:05.000000000 +0100
@@ -971,11 +971,13 @@ static int do_replace(void __user *user,
 	if (ret != 0)
 		goto free_counterstmp;
 
+printk("BEFORE DOWN MUTEX\n");
 	t = find_table_lock(tmp.name, &ret, &ebt_mutex);
 	if (!t) {
 		ret = -ENOENT;
 		goto free_iterate;
 	}
+printk("INSIDE MUTEX PROTECTION\n");
 
 	/* the table doesn't like it */
 	if (t->check && (ret = t->check(newinfo, tmp.valid_hooks)))
@@ -996,6 +998,7 @@ static int do_replace(void __user *user,
 	} else if (table->nentries && !newinfo->nentries)
 		module_put(t->me);
 	/* we need an atomic snapshot of the counters */
+printk("EBTABLES: BEFORE WRITE LOCK\n");
 	write_lock_bh(&t->lock);
 	if (tmp.num_counters)
 		get_counters(t->private->counters, counterstmp,
@@ -1003,7 +1006,9 @@ static int do_replace(void __user *user,
 
 	t->private = newinfo;
 	write_unlock_bh(&t->lock);
+printk("EBTABLES: AFTER WRITE LOCK\n");
 	up(&ebt_mutex);
+printk("EBTABLES: AFTER UP MUTEX\n");
 	/* so, a user can change the chains while having messed up her counter
 	   allocation. Only reason why this is done is because this way the lock
 	   is held only once, while this doesn't bring the kernel into a

--Boundary-00=_/HMoBK1B9Y3ldpH--
