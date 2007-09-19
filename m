From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] [PATCH] RDMA/CMA: Implement rdma_resolve_ip retry
	enhancement.
Date: Wed, 19 Sep 2007 08:43:50 -0700
Message-ID: <adabqbyk6dl.fsf@cisco.com>
References: <200709190022.l8J0MbWt024754@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <200709190022.l8J0MbWt024754@neteffect.com>
	(ggrundstrom@neteffect.com's message of "Tue,
	18 Sep 2007 19:22:37 -0500")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Thanks for the patch...

 > If an application is calling rdma_resolve_ip() and a status of -ENODATA is returned from addr_resolve_local/remote(), the timeout mechanism waits until the application's timeout occurs before rechecking the address resolution status; the application will wait until it's full timeout occurs.  This case is seen when the work thread call to process_req() is made before the arp packet is processed.

I'm having a hard time understanding this changelog.  Could you please
resend with a description that lets me understand:

 - What the current behavior is and what is wrong with that;
 - What the behavior should be;
 - And how your patch changes the behavior to be correct.

 > This patch is in addition to Steve Wise's neigh_event_send patch to initiate neighbour discovery sent on 9/12/2007.

Does this mean it depends on Steve's patch being applied first?

Also please try to keep lines in the changelog to 72 characters or so...

 > @@ -136,6 +137,7 @@ static void set_timeout(unsigned long ti
 >  static void queue_req(struct addr_req *req)
 >  {
 >  	struct addr_req *temp_req;
 > +	unsigned long req_timeout = msecs_to_jiffies(MIN_ADDR_TIMEOUT_MS) + jiffies;
 >  
 >  	mutex_lock(&lock);
 >  	list_for_each_entry_reverse(temp_req, &req_list, list) {
 > @@ -145,8 +147,10 @@ static void queue_req(struct addr_req *r
 >  
 >  	list_add(&req->list, &temp_req->list);
 >  
 > -	if (req_list.next == &req->list)
 > +	if (req_list.next == &req->list) {
 > +		req_timeout = min(req_timeout, req->timeout);
 >  		set_timeout(req->timeout);
 > +	}
 >  	mutex_unlock(&lock);
 >  }

I don't understand this code.  It seems you keep track of the minimum
timeout, and then ignore the value you computed.  What am I missing?

Thanks,
  Roland
