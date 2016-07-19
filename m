From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [PATCH v2 2/3] mac80211: mesh: improve path resolving time
Date: Tue, 19 Jul 2016 08:36:48 -0400
Message-ID: <20160719123648.GC11996@localhost>
References: <20160713114528.24835-1-yanivma@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Maital Hahn <maitalm@ti.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Yaniv Machani <yanivma@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160713114528.24835-1-yanivma@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 13, 2016 at 02:45:25PM +0300, Yaniv Machani wrote:
> When a packet is received for transmission,
> a PREQ frame is sent to resolve the appropriate path to the desired destination.
> After path was established, any sequential PREQ will be sent only after
> dot11MeshHWMPpreqMinInterval, which usually set to few seconds.
> 
> This implementation has an impact in cases where we would like to
> resolve the path quickly.
> A clear example is when a peer was disconnected from us,
> while he acted as a hop to our destination.
> Although the path table will be cleared, the next PREQ frame will be sent only after reaching the MinInterval.
> This will cause unwanted delay, possibly of few seconds until the traffic will resume.
> 
>  	if (!(mpath->flags & MESH_PATH_RESOLVING))
> -		mesh_queue_preq(mpath, PREQ_Q_F_START);
> +		mesh_queue_preq(mpath, PREQ_Q_F_START, true);

What about something like this here instead:

    if (!(mpath->flags & MESH_PATH_RESOLVING)) {
        /* force next preq to be sent without delay */
        ifmsh->last_preq = jiffies - min_preq_int_jiff(sdata) - 1;
        mesh_queue_preq(mpath, PREQ_Q_F_START);
    }

Maybe a little more magic, but it has a comment explaining it and doesn't
add a bool parameter everywhere.  Or, maybe even just do it inside
mesh_queue_preq() based on having PREQ_Q_F_START && !PREQ_Q_F_REFRESH (if
those are the only cases where "true" is passed).

Generally I try to avoid bool parameters where possible because when you
look at a callsite, you don't know immediately what "true" and "false"
mean, and also each one you add doubles the code paths through a given
function.

-- 
Bob Copeland %% http://bobcopeland.com/
