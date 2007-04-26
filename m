From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] RF Kill
Date: Thu, 26 Apr 2007 00:49:51 -0700 (PDT)
Message-ID: <20070426.004951.85412315.davem@davemloft.net>
References: <200704100158.58451.dtor@insightbb.com>
	<200704100229.32393.dtor@insightbb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivdoorn@gmail.com, linville@tuxdriver.com,
	akpm@linux-foundation.org
To: dtor@insightbb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933340AbXDZHtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:49:43 -0400
In-Reply-To: <200704100229.32393.dtor@insightbb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Torokhov <dtor@insightbb.com>
Date: Tue, 10 Apr 2007 02:29:31 -0400

> On Tuesday 10 April 2007 01:58, Dmitry Torokhov wrote:
> > Hi,
> > 
> > This is a modified version of rfkill patch that provides infrastructure
> > for controlling state of RF transmitters found on various cards.
> 
> Well, Andrew found bunch of issues with the patch so here is an
> updated version...

Patch applied, although one part of the locking is slightly
suspect:

> +static void rfkill_task_handler(struct work_struct *work)
> +{
> +	struct rfkill_task *task = container_of(work, struct rfkill_task, work);
> +	enum rfkill_state state;
> +
> +	mutex_lock(&task->mutex);
> +
> +	spin_lock_irq(&task->lock);
> +	state = task->desired_state;
> +	spin_unlock_irq(&task->lock);
> +
> +	if (state != task->current_state) {
> +		rfkill_switch_all(task->type, state);
> +		task->current_state = state;
> +	}
> +
> +	mutex_unlock(&task->mutex);
> +}

I applied this, but...

That lock around the read doesn't make any sense, reads
are atomic on all SMP processors.  You're not going to
see a partial word-update if you take away that lock so
it isn't doing anything.

If locking is really needed here, it probably need to protect
the whole read-modify-write operation transferring the
desired_state to the current_state.

In another code block, this ->desired_state thing is
treated like a boolean instead of the enumeration that
it is supposed to be:

+static void rfkill_schedule_toggle(struct rfkill_task *task)
+{
+	unsigned int flags;
+
+	spin_lock_irqsave(&task->lock, flags);
+
+	if (time_after(jiffies, task->last + msecs_to_jiffies(200))) {
+		task->desired_state = !task->desired_state;
+		task->last = jiffies;
+		schedule_work(&task->work);
+	}
+
+	spin_unlock_irqrestore(&task->lock, flags);
+}

What is going on here?
