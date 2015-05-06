From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 5/6] netns: use a spin_lock to protect nsid
 management
Date: Wed, 6 May 2015 16:05:57 +0200
Message-ID: <20150506140557.GA26920@pox.localdomain>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>
 <1430906288-5108-6-git-send-email-nicolas.dichtel@6wind.com>
 <20150506122314.GJ25248@pox.localdomain>
 <554A19CD.2070608@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, ebiederm@xmission.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f195.google.com ([209.85.212.195]:33181 "EHLO
	mail-wi0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbbEFOGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:06:01 -0400
Received: by wivz2 with SMTP id z2so2594274wiv.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 07:05:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <554A19CD.2070608@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 at 03:40pm, Nicolas Dichtel wrote:
> Le 06/05/2015 14:23, Thomas Graf a ?crit :
> >On 05/06/15 at 11:58am, Nicolas Dichtel wrote:
> >>+/* Should be called with nsid_lock held. If a new id is assigned, the bool alloc
> >>+ * is set to true, thus the caller knows that the new id must be notified via
> >>+ * rtnl.
> >>+ */
> >>  static int __peernet2id(struct net *net, struct net *peer, bool *alloc)
> >>  {
> >>  	int id = idr_for_each(&net->netns_ids, net_eq_idr, peer);
> >>  	bool alloc_it = *alloc;
> >>
> >>-	ASSERT_RTNL();
> >>-
> >>  	*alloc = false;
> >>
> >>  	/* Magic value for id 0. */
> >
> >If split into __peernet2id() and __peernet2id_alloc() then this could
> >live with RCU protection I guess so we only take the lock when we
> >actually allocate.
> >
> The description of idr_for_each says:
> "The caller must serialize idr_for_each() vs idr_get_new() and idr_remove()."
> 
> So, if I understand well, the lock is always needed.

Ah, I looked at idr_alloc which says:

 * The user is responsible for exclusively synchronizing all operations
 * which may modify @idr.  However, read-only accesses such as idr_find()
 * or iteration can be performed under RCU read lock provided the user
 * destroys @ptr in RCU-safe way after removal from idr.
