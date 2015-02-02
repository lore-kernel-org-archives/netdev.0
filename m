From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Mon, 2 Feb 2015 02:38:14 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EE80DE@RTITMBSV03.realtek.com.tw>
References: <0835B3720019904CB8F7AA43166CEEB2EE6E76@RTITMBSV03.realtek.com.tw>
	<20150119.215220.720365670558757349.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2EE6E9F@RTITMBSV03.realtek.com.tw>
 <20150124.224342.425895080003524375.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB2EE77A2@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:51185 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163AbbBBCiX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Feb 2015 21:38:23 -0500
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2EE77A2@RTITMBSV03.realtek.com.tw>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  David Miller [mailto:davem@davemloft.net] 
> > Sent: Sunday, January 25, 2015 2:44 PM
> > What keeps rtl_start_rx() from running in parallel with
> > r8152_submit_rx(), or any other accessor of the RX agg->list?
> 
> Forgive my poor English. I would try to describe them clearly.
> The steps about the rx agg->list would be
> 1. carrier on or autoresume occurs.
> 2. Call rtl_start_rx().
> 3. Rx agg->list flows between device and tp->rx_done.
> 4. carrier off or autosuspend occurs.
> 5. call rtl_stop_rx().
> 
> The rtl_start_rx() would only be called when the linking
> status is changed from off to on or the auto resume occurs.
> And rtl_start_rx() would reinitialize the tp->rx_done and
> all of the rx agg->list. After step 2, the rx agg->list
> would flow between the usb host controller and the driver.
> If r8152_submit_rx() is success, the driver wouldn't own the
> rx agg->list until it is returned from the usb host controller.
> If r8152_submit_rx() is fail, the driver would still own the
> rx agg->list, and queue it to the tp->rx_done with spin lock
> for next try.
> 
> If the status stays in step 3, only the rx_bottom() would submit
> the rx agg. The rtl_start_rx() wouldn't be called suddenly,
> unless the linking down or auto suspend occur first and linking
> on or auto resume occur again. If linking down or auto suspend
> occur, rtl_stop_rx() would be called (step 5). After this step,
> rx_bottom() wouldn't submit rx, and all rx agg->list would stop
> flowing. That is, the tp->rx_done and all rx agg->list wouldn't
> be changed until the next rtl_start_rx() is called.
> 
> Therefore, the flow for each rx agg->list would be
> a. submittd by rtl_start_rx().
> b. goto step c if success, otherwise goto step d.
> c. completed by usb host controller.
> d. queued to tp->rx_done with spin lock.
> e. dequeue from tp->rx_done with spin lock by rx_botoom().
> f. goto step i if link down, otherwise goto step g.
> g. submitted by rx_botoom().
> h. goto step b.
> i. goto step a if link on.
> 
> And the patch change the step g to g1.
> g1. submitted by rx_botoom() if (!ret), otherwise goto step d.

Excuse me. Any other question or suggestion for this patch?
 
Best Regards,
Hayes
