From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] (3/6) ipvs -- use list_for_each_entry macro's
Date: Sun, 21 Sep 2003 10:54:55 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309210934460.1468-100000@u.domain.uli>
References: <20030916141750.53bbb04e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>, <lvs-users@LinuxVirtualServer.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916141750.53bbb04e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	It seems some places become inefficient. May be we have
to introduce list_for_each_entry_continue?:

 * list_for_each_entry_continue	-	iterate over list of given type
 *			continuing after existing point
 * @pos:	the type * to use as a loop counter.
 * @head:	the head for your list.
 * @member:	the name of the list_struct within the struct.
 */
#define list_for_each_entry_continue(pos, head, member)			\
	for (pos = list_entry(pos->member.next, typeof(*pos), member),	\
		     prefetch(pos->member.next);			\
	     &pos->member != (head);					\
	     pos = list_entry(pos->member.next, typeof(*pos), member),	\
		     prefetch(pos->member.next))


below are some comments, there are some strange changes:

On Tue, 16 Sep 2003, Stephen Hemminger wrote:

> diff -Nru a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
> --- a/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:08:39 2003
> +++ b/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:08:39 2003
> @@ -214,18 +214,14 @@
>   */
>  void unregister_ip_vs_app(struct ip_vs_app *app)
>  {
> -	struct ip_vs_app *inc;
> -	struct list_head *l = &app->incs_list;
> +	struct ip_vs_app *inc, *nxt;
>
>  	down(&__ip_vs_app_mutex);
>
> -	while (l->next != l) {
> -		inc = list_entry(l->next, struct ip_vs_app, a_list);
> +	list_for_each_entry_safe(inc, nxt, &app->incs_list, a_list) {
>  		ip_vs_app_inc_release(inc);
>  	}

	What happens with this list_del?:

>
> -	list_del(&app->a_list);
> -
>  	up(&__ip_vs_app_mutex);
>
>  	/* decrease the module use count */

> diff -Nru a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
> --- a/net/ipv4/ipvs/ip_vs_rr.c	Tue Sep 16 14:08:39 2003
> +++ b/net/ipv4/ipvs/ip_vs_rr.c	Tue Sep 16 14:08:39 2003
> @@ -57,7 +57,7 @@
>  static struct ip_vs_dest *
>  ip_vs_rr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
>  {
> -	register struct list_head *p, *q;
> +	struct list_head *p, *q;
>  	struct ip_vs_dest *dest;
>
>  	IP_VS_DBG(6, "ip_vs_rr_schedule(): Scheduling...\n");
> @@ -73,12 +73,12 @@
>  			continue;
>  		}

	new empty line, may be your changes to ip_vs_rr.c are
not completed/actual? :) :

>
> +
>  		dest = list_entry(q, struct ip_vs_dest, n_list);
>  		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
>  		    atomic_read(&dest->weight) > 0)
>  			/* HIT */
>  			goto out;

	Why this line is deleted?:

> -		q = q->next;
>  	} while (q != p);
>  	write_unlock(&svc->sched_lock);
>  	return NULL;


> diff -Nru a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
> --- a/net/ipv4/ipvs/ip_vs_sed.c	Tue Sep 16 14:08:39 2003
> +++ b/net/ipv4/ipvs/ip_vs_sed.c	Tue Sep 16 14:08:39 2003
> @@ -85,7 +85,6 @@
>  static struct ip_vs_dest *
>  ip_vs_sed_schedule(struct ip_vs_service *svc, struct iphdr *iph)
>  {
> -	register struct list_head *l, *e;
>  	struct ip_vs_dest *dest, *least;
>  	unsigned int loh, doh;
>
> @@ -104,9 +103,7 @@
>  	 * new connections.
>  	 */
>
> -	l = &svc->destinations;
> -	for (e=l->next; e!=l; e=e->next) {
> -		least = list_entry(e, struct ip_vs_dest, n_list);
> +	list_for_each_entry(least, &svc->destinations, n_list) {
>  		if (!(least->flags & IP_VS_DEST_F_OVERLOAD) &&
>  		    atomic_read(&least->weight) > 0) {
>  			loh = ip_vs_sed_dest_overhead(least);
> @@ -119,9 +116,7 @@
>  	 *    Find the destination with the least load.
>  	 */

	Inefficient, list_for_each_entry_continue?:

>    nextstage:
> -	for (e=e->next; e!=l; e=e->next) {
> -		dest = list_entry(e, struct ip_vs_dest, n_list);
> -
> +	list_for_each_entry(dest, &svc->destinations, n_list) {
>  		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>  			continue;
>  		doh = ip_vs_sed_dest_overhead(dest);


> diff -Nru a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
> --- a/net/ipv4/ipvs/ip_vs_wlc.c	Tue Sep 16 14:08:39 2003
> +++ b/net/ipv4/ipvs/ip_vs_wlc.c	Tue Sep 16 14:08:39 2003
> @@ -73,7 +73,6 @@
>  static struct ip_vs_dest *
>  ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
>  {
> -	register struct list_head *l, *e;
>  	struct ip_vs_dest *dest, *least;
>  	unsigned int loh, doh;
>
> @@ -92,9 +91,7 @@
>  	 * new connections.
>  	 */
>
> -	l = &svc->destinations;
> -	for (e=l->next; e!=l; e=e->next) {
> -		least = list_entry(e, struct ip_vs_dest, n_list);
> +	list_for_each_entry(least, &svc->destinations, n_list) {
>  		if (!(least->flags & IP_VS_DEST_F_OVERLOAD) &&
>  		    atomic_read(&least->weight) > 0) {
>  			loh = ip_vs_wlc_dest_overhead(least);
> @@ -107,9 +104,7 @@
>  	 *    Find the destination with the least load.
>  	 */

	Shorter, not broken but inefficient, list_for_each_entry_continue?:

>    nextstage:
> -	for (e=e->next; e!=l; e=e->next) {
> -		dest = list_entry(e, struct ip_vs_dest, n_list);
> -
> +	list_for_each_entry(dest, &svc->destinations, n_list) {
>  		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
>  			continue;
>  		doh = ip_vs_wlc_dest_overhead(dest);

> diff -Nru a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
> --- a/net/ipv4/ipvs/ip_vs_wrr.c	Tue Sep 16 14:08:39 2003
> +++ b/net/ipv4/ipvs/ip_vs_wrr.c	Tue Sep 16 14:08:39 2003
> @@ -56,25 +56,22 @@
>
>  static int ip_vs_wrr_gcd_weight(struct ip_vs_service *svc)
>  {
> -	register struct list_head *l, *e;
>  	struct ip_vs_dest *dest;
>  	int weight;
>  	int g = 1;
>
> -	l = &svc->destinations;
> -	for (e=l->next; e!=l; e=e->next) {
> -		dest = list_entry(e, struct ip_vs_dest, n_list);
> +	list_for_each_entry(dest, &svc->destinations, n_list) {
>  		weight = atomic_read(&dest->weight);
>  		if (weight > 0) {
>  			g = weight;
> -			break;
> +			goto search_gcd;
>  		}
>  	}
> -	if (e == l)
> -		return g;
>
> -	for (e=e->next; e!=l; e=e->next) {
> -		dest = list_entry(e, struct ip_vs_dest, n_list);
> +	return g;
> +

	It still does not look good:

> + search_gcd:
> +	list_for_each_entry(dest, &svc->destinations, n_list) {
>  		weight = atomic_read(&dest->weight);
>  		if (weight > 0)
>  			g = gcd(weight, g);
> @@ -89,13 +86,10 @@

	What about such version?:

static int ip_vs_wrr_gcd_weight(struct ip_vs_service *svc)
{
	struct ip_vs_dest *dest;
	int weight;
	int g = 0;

	list_for_each_entry(dest, &svc->destinations, n_list) {
		weight = atomic_read(&dest->weight);
		if (weight > 0) {
			if (g > 0)
				g = gcd(weight, g);
			else
				g = weight;
		}
	}

	return g?: 1;
}

Regards

--
Julian Anastasov <ja@ssi.bg>
