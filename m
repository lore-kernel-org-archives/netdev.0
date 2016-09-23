From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 08/15] rxrpc: Fix call timer
Date: Fri, 23 Sep 2016 21:04:31 +0300
Message-ID: <9efafc3e-5f19-598c-ee0c-def748eeb78a@cogentembedded.com>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
 <147464377267.5090.12222734463447533990.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147464377267.5090.12222734463447533990.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/23/2016 06:16 PM, David Howells wrote:

> Fix the call timer in the following ways:
>
>  (1) If call->resend_at or call->ack_at are before or equal to the current
>      time, then ignore that timeout.
>
>  (2) If call->expire_at is before or equal to the current time, then don't
>      set the timer at all (possibly we should queue the call).
>
>  (3) Don't skip modifying the timer if timer_pending() is true.  This
>      indicates that the timer is working, not that it has expired and is
>      running/waiting to run its expiry handler.
>
> Also call rxrpc_set_timer() to start the call timer going rather than
> calling add_timer().
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  net/rxrpc/call_event.c  |   25 ++++++++++++++-----------
>  net/rxrpc/call_object.c |    4 ++--
>  2 files changed, 16 insertions(+), 13 deletions(-)
>
> diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
> index 3a7f90a2659c..8bc5c8e37ab4 100644
> --- a/net/rxrpc/call_event.c
> +++ b/net/rxrpc/call_event.c
> @@ -28,24 +28,27 @@ void rxrpc_set_timer(struct rxrpc_call *call)
>  {
>  	unsigned long t, now = jiffies;
>
> -	_enter("{%ld,%ld,%ld:%ld}",
> -	       call->ack_at - now, call->resend_at - now, call->expire_at - now,
> -	       call->timer.expires - now);
> -
>  	read_lock_bh(&call->state_lock);
>
>  	if (call->state < RXRPC_CALL_COMPLETE) {
> -		t = call->ack_at;
> -		if (time_before(call->resend_at, t))
> +		t = call->expire_at;
> +		if (time_before_eq(t, now))
> +			goto out;
> +
> +		if (time_after(call->resend_at, now) &&
> +		    time_before(call->resend_at, t))
>  			t = call->resend_at;
> -		if (time_before(call->expire_at, t))
> -			t = call->expire_at;
> -		if (!timer_pending(&call->timer) ||
> -		    time_before(t, call->timer.expires)) {
> -			_debug("set timer %ld", t - now);
> +
> +		if (time_after(call->ack_at, now) &&
> +		    time_before(call->ack_at, t))
> +			t = call->ack_at;
> +
> +		if (call->timer.expires != t || !timer_pending(&call->timer)) {
>  			mod_timer(&call->timer, t);
>  		}

    CodingStyle: {} not needed now.

[...]

MBR, Sergei
