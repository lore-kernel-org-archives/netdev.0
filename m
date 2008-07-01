From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Passive OS fingerprinting.
Date: Wed, 2 Jul 2008 01:21:40 +0400
Message-ID: <20080701212139.GA18619@2ka.mipt.ru>
References: <20080701113927.GA16343@2ka.mipt.ru> <20080701195648.GD7488@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080701195648.GD7488@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul.

On Tue, Jul 01, 2008 at 12:56:48PM -0700, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > static int ipt_osf_proc_read(char *buf, char **start, off_t off, int count,
> > 			 int *eof, void *data)
> > {
> > 	struct ipt_osf_finger *f = NULL;
> > 	int i, __count, err;
> > 
> > 	*eof = 1;
> > 	__count = count;
> > 	count = 0;
> > 
> > 	rcu_read_lock();
> > 	list_for_each_entry(f, &ipt_finger_list, flist) {
> 
> Does the above need to be list_for_each_entry_rcu()?

Yeah, I messed with procfs handlers.

...

> > static int ipt_osf_proc_write(struct file *file, const char *buffer,
> > 			  unsigned long count, void *data)
> > {
> > 	int cnt, i;
> > 	char obuf[MAXOPTSTRLEN];
> > 	struct ipt_osf_finger *finger, *n;
> > 	char *pbeg, *pend;
> > 
> > 	if (count > 0xffff)
> > 		return -E2BIG;
> > 
> > 	if (count == strlen(OSFFLUSH) && !strncmp(buffer, OSFFLUSH, strlen(OSFFLUSH))) {
> > 		int i = 0;
> > 		synchronize_rcu();
> > 		spin_lock_bh(&ipt_osf_lock);
> > 		list_for_each_entry_safe(finger, n, &ipt_finger_list, flist) {
> 
> This is OK -- we hold the update-side lock, so don't need _rcu.
> 
> > 			i++;
> > 			list_del_rcu(&finger->flist);
> > 			ipt_osf_finger_free(finger);
> 
> Why is it safe to immediately free the element that we just removed from
> an RCU-protected list?  The above synchronize_rcu() won't help us given
> that it is still in the list at that point.
> 
> This could be fixed by using call_rcu() in ipt_osf_finger_free().

Yup, it is safe on UP machine, since without lock it is only accessed
from the bottom half, which is disabled, but running it on different CPU
will lead to crash.

procfs was not a very good choice here :)

> > 	cnt = snprintf(finger->details,
> > 		       ((count - (pbeg - buffer) + 1) >
> > 			MAXDETLEN) ? MAXDETLEN : (count - (pbeg - buffer) + 1),
> > 		       "%s", pbeg);
> > 
> > 	log("%s - %s[%s] : %s\n",
> > 	    finger->genre, finger->version, finger->subtype, finger->details);
> > 
> > 	ipt_osf_parse_opt(finger->opt, &finger->opt_num, obuf, sizeof(obuf));
> > 
> > 	synchronize_rcu();
> 
> I don't understand what this synchronize_rcu() is doing for us.
> 
> Is the idea to make sure that all RCU readers see the prior deletes as
> having happened before we do the below addition?  If so, please add a
> comment to this effect.

Just to be sure, that  return from the call does update the list.
It is not needed in practice.

> > static void __devexit ipt_osf_fini(void)
> > {
> > 	struct ipt_osf_finger *f, *n;
> > 
> > 	remove_proc_entry("osf", proc_net_netfilter);
> > 	xt_unregister_match(&ipt_osf_match);
> > 
> > 	list_for_each_entry_safe(f, n, &ipt_finger_list, flist) {
> 
> Why is it safe to do the above without being in an RCU read-side critical
> section?  Have all possible RCU readers somehow been banished?  If so,
> how have they been banished?
> 
> > 		list_del(&f->flist);
> 
> Ditto for why the list_del() is safe without the update-side lock and
> why it doesn't have to be list_del_rcu().

Procfs was messed, it should use proper rcu freeing path, and although
procefs entry was removed, there may be some reference.

Thanks a lot for your review Paul.

-- 
	Evgeniy Polyakov
