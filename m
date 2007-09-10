From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 03/16] net: Basic network namespace infrastructure.
Date: Mon, 10 Sep 2007 00:32:43 -0600
Message-ID: <m1ejh7rpx0.fsf@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<20070909003308.GA10417@linux.vnet.ibm.com>
	<m1fy1otarm.fsf@ebiederm.dsl.xmission.com>
	<20070909164547.GD10417@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:57706 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753674AbXIJGdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 02:33:14 -0400
In-Reply-To: <20070909164547.GD10417@linux.vnet.ibm.com> (Paul E. McKenney's
	message of "Sun, 9 Sep 2007 09:45:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> writes:

>> I know I cannot use get_net for the reference in in /proc because
>> otherwise I could not release the network namespace unless I was to
>> unmount the filesystem, which is not a desirable property.
>> 
>> I think I can change the idiom to:
>> 
>> struct net *maybe_get_net(struct net *net)
>> {
>>         if (!atomic_inc_not_zero(&net->count))
>>         	net = NULL;
>> 	return net;               
>> }
>> 
>> Which would make dev_seq_open be:
>> 
>> static int dev_seq_open(struct inode *inode, struct file *file)
>> {
>> 	struct seq_file *seq;
>> 	int res;
>> 	res =  seq_open(file, &dev_seq_ops);
>> 	if (!res) {
>> 		seq = file->private_data;
>> 		seq->private = maybe_get_net(PROC_NET(inode));
>> 		if (!seq->private) {
>> 			res = -ENOENT;
>>                         seq_release(inode, file);
>> 		}
>> 	}
>> 	return res;
>> }
>> 
>> I'm still asking myself if I need any kind of locking to ensure
>> struct net does not go away in the mean time, if so rcu_read_lock()
>> should be sufficient.
>
> Agreed -- and it might be possible to leverage the existing locking
> in the /proc code.

Yes.  The generic /proc code takes care of this.  It appears
to ensure that any ongoing operations will be waited for and
no more operations will be started once remove_proc_entry
is called.  So I just need the maybe_get_net thing to have
safe ref counting.

That is what I thought but I figured I would review that part while
I was looking at everything.

Eric
