From: Florian Mickler <florian@mickler.org>
Subject: Re: [RFC PATCH 1/2] mac80211: make max_network_latency notifier
 atomic safe
Date: Wed, 9 Jun 2010 14:16:43 +0200
Message-ID: <20100609141643.14e9aedc@schatten.dmk.lab>
References: <1276074915-26879-1-git-send-email-florian@mickler.org>
	<1276076287.3727.15.camel@jlt3.sipsolutions.net>
	<20100609122050.1dd18132@schatten.dmk.lab>
	<1276080128.14580.5.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pm list <linux-pm@lists.linux-foundation.org>,
	james.bottomley@suse.de, markgross@thegnar.org,
	mgross@linux.intel.com,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Javier Cardona <javier@cozybit.com>, Jouni Malinen <j@w1.fi>,
	Rui Paulo <rpaulo@gmail.com>,
	Kalle Valo <kalle.valo@nokia.com>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276080128.14580.5.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 09 Jun 2010 12:42:08 +0200
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Wed, 2010-06-09 at 12:20 +0200, Florian Mickler wrote:
> 
> > A third possibility would be to make it dependent on the
> > type of the constraint, if blocking notifiers are allowed or not. 
> > But that would sacrifice API consistency (update_request for one
> > constraint is allowed to be called in interrupt context and
> > update_request for another would be not).
> 
> I don't see what's wrong with the fourth possibility: Allow calling
> pm_qos_update_request() from atomic context, but change _it_ to schedule
> off a work that calls the blocking notifier chain. That avoids the
> complexity in notify-API users since they have process context, and also
> in request-API users since they can call it from any context.
> 
> johannes

That was also my first idea, but then I thought about qos and thought
atomic notification are necessary.
Do you see any value in having atomic
notification? 

I have the following situation before my eyes:

	Driver A gets an interrupt and needs (to service that
	interrupt) the cpu to guarantee a latency of X because the
	device is a bit icky.

Now, in that situation, if we don't immediately (without scheduling in
between) notify the system to be in that latency-mode the driver won't
function properly. Is this a realistic scene?

At the moment we only have process context notification and only 2
listeners.

I think providing for atomic as well as "relaxed" notification could be
useful. 

If atomic notification is deemed unnecessary, I have no
problems to just use schedule_work() in update request.
Anyway, it is probably best to split this. I.e. first make
update_request callable from atomic contexts with doing the
schedule_work in update_request and then
as an add on provide for constraints_objects with atomic notifications.

Flo
