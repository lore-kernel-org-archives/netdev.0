From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TSO and IPoIB performance degradation
Date: Mon, 20 Mar 2006 15:00:29 -0800 (PST)
Message-ID: <20060320.150029.109814021.davem@davemloft.net>
References: <20060320114933.GA3058@xi.wantstofly.org>
	<20060320120407.GY29929@mellanox.co.il>
	<20060320150941.GD16108@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, rick.jones2@hp.com,
	linux-kernel@vger.kernel.org, openib-general@openib.org,
	buytenh@wantstofly.org, arjan@infradead.org
Return-path: <openib-general-bounces@openib.org>
To: bcrl@kvack.org
In-Reply-To: <20060320150941.GD16108@kvack.org>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Mon, 20 Mar 2006 10:09:42 -0500

> Wouldn't it make sense to strech the ACK when the previous ACK is still in 
> the TX queue of the device?  I know that sort of behaviour was always an 
> issue on modem links where you don't want to send out redundant ACKs.

I thought about doing some similar trick with TSO, wherein we would
not defer a TSO send if all the previous packets sent are out of the
device transmit queue.  The idea was the prevent the pipe from ever
emptying which is the danger of deferring too much for TSO.

This has several problems.  It's hard to implement.  You have to
decide if you want precise state, thereby checking the TX descriptors.
Or you go for imprecise but easier to implement, which is very
imprecise and therefore not very useful state, by just checking the
SKB refcount or similar which means that you find out it's left the TX
queue after the TX purge interrupt which can be a long time after the
event and by then the pipe has empties which is what you were trying
to prevent.

Lastly, you don't want to touch remote cpu state which is what such
a hack is going to end up doing much of the time.
