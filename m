From: David Miller <davem@davemloft.net>
Subject: [ofa-general] Re: [Bug,
 PATCH and another Bug] Was: Fix refcounting problem with
 netif_rx_reschedule()
Date: Wed, 19 Sep 2007 09:05:57 -0700 (PDT)
Message-ID: <20070919.090557.24612742.davem@davemloft.net>
References: <20070919115403.19455.65941.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: krkumar2@in.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070919115403.19455.65941.sendpatchset@K50wks273871wss.in.ibm.com>
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

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Wed, 19 Sep 2007 17:24:03 +0530

> Note: during steps F-H and C-E, priv/napi is read/modified by both cpu's
> 	which is another bug relating to the same race.
> 
> I guess the above patch is not required if this bug (in IPoIB) is fixed?

The NAPI_STATE_SCHED flag bit should provide all of the necessary
synchornization.

Only the setter of that bit should add the NAPI instance to the
polling list.

The polling loop runs atomically on the cpu where the NAPI instance
got added to the per-cpu polling list.  And therefore decisions to
complete NAPI are serialized too.

That serialized completion decision is also when the list deletion
occurs.

I'm starting to suspect the whole problem comes from the resched
facility, and now I really don't blame Stephen for trying to delete
it.  Semantically it really makes things very difficult, especially
wrt. to the atomicity of the list handling.
