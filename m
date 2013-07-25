From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2] bridge: disable snooping if there is no
	querier
Date: Thu, 25 Jul 2013 09:01:40 -0700
Message-ID: <20130725090140.658f33f7@nehalam.linuxnetplumber.net>
References: <1374757046-12463-1-git-send-email-linus.luessing@web.de>
	<1374760580-12920-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Adam Baker <linux@baker-net.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Linus =?ISO-8859-1?B?TPxzc2luZw==?= <linus.luessing@web.de>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1374760580-12920-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Jul 2013 15:56:20 +0200
Linus L=FCssing <linus.luessing@web.de> wrote:

> =20
> +static void br_multicast_update_querier_timer(struct net_bridge *br,
> +					      unsigned long max_delay)
> +{
> +	if (!timer_pending(&br->multicast_querier_timer))
> +		atomic64_set(&br->multicast_querier_delay_time,
> +			     jiffies + max_delay);
> +
> +	mod_timer(&br->multicast_querier_timer,
> +		  jiffies + br->multicast_querier_interval);
> +}
> +

Isn't this test racing with timer expiration.

static void br_multicast_update_querier_timer(struct net_bridge *br,
					      unsigned long max_delay)
{
	if (!timer_pending(&br->multicast_querier_timer))
		atomic64_set(&br->multicast_querier_delay_time,
			     jiffies + max_delay);
What if timer completes here?

	mod_timer(&br->multicast_querier_timer,
		  jiffies + br->multicast_querier_interval);
}


And another race if timer goes off?

static void br_multicast_update_querier_timer(struct net_bridge *br,
					      unsigned long max_delay)
{
	if (!timer_pending(&br->multicast_querier_timer))
		atomic64_set(&br->multicast_querier_delay_time,
			     jiffies + max_delay);
Timer fires here...?

	mod_timer(&br->multicast_querier_timer,
		  jiffies + br->multicast_querier_interval);
}
