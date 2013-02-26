From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: batman-adv: gpf in batadv_slide_own_bcast_window
Date: Tue, 26 Feb 2013 13:52:46 +0800
Message-ID: <201302261352.47191.lindner_marek@yahoo.de>
References: <5127A2AF.9030502@oracle.com> <20130222170621.GU3523@ritirata.org>
 <5127BAD2.1040007@oracle.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Simon Wunderlich <siwu-MaAgPAbsBIVS8oHt8HbXEIQuADTiUCJX@public.gmane.org>, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <5127BAD2.1040007-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Saturday, February 23, 2013 02:37:06 Sasha Levin wrote:
> I'm confused about how batadv_orig_hash_del_if removes an interface from
> the hashtable. I see the hashtable is using rcu to protect it, but when we
> delete an entry we free it straight away by calling
> batadv_orig_node_del_if() and not going through kfree_rcu().
> 
> Is there a reason behind doing that, or might it be the cause of the
> problem we're seeing here?

Maybe I am overlooking something but it seems to me access to this memory is 
protected by the same lock: orig_node->ogm_cnt_lock
Before batadv_orig_node_del_if() is called this lock is acquired and 
batadv_slide_own_bcast_window() also attempts acquire the orig_node-
>ogm_cnt_lock spinlock before writing to this chunk of memory.

Do we know for certain that batadv_orig_hash_del_if() is involved or is that a 
guess at this point ? If you ask me the next for-loop in 
batadv_orig_hash_del_if() looks more suspicious than the first one. The 
interfaces get renumbered without any protection. Could be a regression from 
the orig_hash_lock removal (the comments refer to a now inexisting lock).

Cheers,
Marek
