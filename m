From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 5/6 v2] IB: IP address based RDMA
	connection manager
Date: Mon, 13 Mar 2006 07:43:28 -0800
Message-ID: <adabqwafizj.fsf@cisco.com>
References: <ORSMSX401FRaqbC8wSA0000000e@orsmsx401.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Sean Hefty" <sean.hefty@intel.com>
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

It seems that cma_detach_from_dev():

 > +static void cma_detach_from_dev(struct rdma_id_private *id_priv)
 > +{
 > +	list_del(&id_priv->list);
 > +	if (atomic_dec_and_test(&id_priv->cma_dev->refcount))
 > +		wake_up(&id_priv->cma_dev->wait);
 > +	id_priv->cma_dev = NULL;
 > +}

doesn't need to do atomic_dec_and_test(), because it is never dropping
the last reference to id_priv (and in fact if it was, the last line
would be a use-after-free bug).

Does it make sense to replace it with:

	static void cma_detach_from_dev(struct rdma_id_private *id_priv)
	{
		list_del(&id_priv->list);
		/*
		 * cma_detach_from_dev() will never be dropping the last
		 * reference to id_priv, so no need to test here.
		 */
		atomic_dec(&id_priv->cma_dev->refcount);
		id_priv->cma_dev = NULL;
	}

on my x86_64 build that's worth

	add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-40 (-40)
	function                                     old     new   delta
	cma_detach_from_dev                          106      66     -40

 - R.
