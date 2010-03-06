From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and devices
	(v5)
Date: Sat, 06 Mar 2010 09:08:43 -0800
Message-ID: <87bpf1idic.fsf@caffeine.danplanet.com>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-3-git-send-email-danms@us.ibm.com>
	<4B91D1A3.9030404@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org,
        den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B91D1A3.9030404-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Fri\, 05 Mar 2010 22\:53\:07 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

OL> What about leak detection ?
OL> Aren't we missing {netns,netdev}_users()?

This is something I need to give more thought to, but it's not as easy
as it sounds.  Network devices aren't released at the last put() like
a lot of other things, and my initial attempts to reconcile the
refcount after a checkpoint operation have not been successful.

However, I'm not sure that it's as important here, because AFAIK, a
network device can only exist in one network namespace at a time.  If
we're checkpointing a netdev, it's because we are checkpointing the
namespace that it lives in.  Making sure the netns isn't leaked out of
the process tree would be much easier and just as effective, no?

>> +config CHECKPOINT_NETNS
>> +       bool
>> +       default y if NET && NET_NS && CHECKPOINT
>> +

OL> Did you mean this to be visible (settable) by the user ?

No, it was specifically supposed to enable itself when those other
items are enabled, but not be a user adjustable toggle.  I had a
discussion with Serge about it and we came to this as a solution,
although I don't remember what the problem we started with was.  I'll
dig through my IRC logs to see if I can figure it out.

>> + retry:
>> +	if (++pages > 4) {
>> +		addrs = -E2BIG;
>> +		goto out;
>> +	}

OL> Why 4 ?

It's just a sanity limit.

OL> Do we really need this special case ?  I'd be happy with a ckpt_err()
OL> for any error - and the actual error number would be useful to tell
OL> which case it was.

Unless I'm missing something, you asked for this specifically:

https://lists.linux-foundation.org/pipermail/containers/2010-February/022844.html

OL> Isn't this check redundant ?  I expect it to fail promptly in
OL> checkpoint_netdev() above.

No, as I've said a couple of times previously, this isn't the only way
we can arrive at a netdev for checkpointing.  This case is the one
where we're marching through the netns and find a netdev that is not
supported.  The other is where we arrive at a device as a peer of
another device, so the other check may come into play at times where
this one doesn't and vice versa.

OL> This may be a bit simpler if you move the first deferqueue_add()
OL> forward to just before the other one. Or better: change dq_netdev
OL> to have two pointers, dev and peer (if any is null, the cleanup
OL> function will skip).

The reason it is this messy is because of the way network devices are
deallocated.  Since they don't destroy themselves on the final put(),
we have to explicitly call unregister_netdev() on them when we know
they're no longer used (else we block).  Once we've added them to the
deferqueue, we can no longer destroy them here because a reference is
held and the deferqueue will run afterwards.

The ordering of this is a result of me injecting failures at each step
and working it out until I got it to not block on unregistering either
of the devices in all of the error paths.  That's not to say it's the
best way, but there is a reason it's ordered the way it is.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
