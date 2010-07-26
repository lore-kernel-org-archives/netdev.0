From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH UPDATED 1/3] vhost: replace vhost_workqueue with per-vhost
 kthread
Date: Mon, 26 Jul 2010 21:31:58 +0200
Message-ID: <4C4DE2AE.40302@kernel.org>
References: <4C06A580.9060300@kernel.org> <20100722155840.GA1743@redhat.com> <4C48B664.9000109@kernel.org> <20100724191447.GA4972@redhat.com> <4C4BEAA2.6040301@kernel.org> <20100726152510.GA26223@redhat.com> <4C4DAB14.5050809@kernel.org> <20100726155014.GA26412@redhat.com> <4C4DB247.9060709@kernel.org> <4C4DB466.6000409@kernel.org> <20100726165114.GA27353@redhat.com> <4C4DDE7E.8030406@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Oleg Nesterov <oleg@redhat.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:36511 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752074Ab0GZTdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 15:33:10 -0400
In-Reply-To: <4C4DDE7E.8030406@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 07/26/2010 09:14 PM, Tejun Heo wrote:
> On 07/26/2010 06:51 PM, Michael S. Tsirkin wrote:
>> I noticed that with vhost, flush_work was getting the worker
>> pointer as well. Can we live with this API change?
> 
> Yeah, the flushing mechanism wouldn't work reliably if the work is
> queued to a different worker without flushing, so yeah passing in
> @worker might actually be better.

Thinking a bit more about it, it kind of sucks that queueing to
another worker from worker->func() breaks flush.  Maybe the right
thing to do there is using atomic_t for done_seq?  It pays a bit more
overhead but maybe that's justifiable to keep the API saner?  It would
be great if it can be fixed somehow even if it means that the work has
to be separately flushed for each worker it has been on before being
destroyed.

Or, if flushing has to be associated with a specific worker anyway,
maybe it would be better to move the sequence counter to
kthread_worker and do it similarly with the original workqueue so that
work can be destroyed once execution starts?  Then, it can at least
remain semantically identical to the original workqueue.

Thanks.

-- 
tejun
