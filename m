From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] tipc: checking returns and Re: Possible Circular Locking in TIPC
Date: Fri, 5 Jan 2007 08:58:57 +0100
Message-ID: <20070105075857.GB1675@ff.dom.local>
References: <20061228121702.GA5076@ff.dom.local> <459C396B.1090508@ericsson.com> <20070104122843.GC3175@ff.dom.local> <459D2854.1000405@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Sesterhenn <snakebyte@gmx.de>,
	Per Liden <per.liden@ericsson.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"'tipc-discussion\@lists\.sourceforge\.net'"
	<tipc-discussion@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:51974 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161019AbXAEH5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 02:57:15 -0500
To: Jon Maloy <jon.maloy@ericsson.com>
Content-Disposition: inline
In-Reply-To: <459D2854.1000405@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 04:16:20PM +0000, Jon Maloy wrote:
> Regards
> ///jon
> 
> Jarek Poplawski wrote:
> 
> >
> >I know lockdep is sometimes
> >too careful but nevertheless some change is needed
> >to fix a real bug or give additional information
> >to lockdep. 
> > 
> >
> I don't know lockdep well enough yet, but I will try to find out if that
> is possible.

If you are sure there is no circular locking possible
between these two functions and this entry->lock here
isn't endangered by other functions, you could try to
make lockdep "silent" like this: 


        write_lock_bh(&ref_table_lock);
        if (tipc_ref_table.first_free) {
                index = tipc_ref_table.first_free;
                entry = &(tipc_ref_table.entries[index]);
                index_mask = tipc_ref_table.index_mask;
                /* take lock in case a previous user of entry still holds it */

-                spin_lock_bh(&entry->lock, );
+		local_bh_disable();
+		spin_lock_nested(&entry->lock, SINGLE_DEPTH_NESTING);

                next_plus_upper = entry->data.next_plus_upper;
                tipc_ref_table.first_free = next_plus_upper & index_mask;
                reference = (next_plus_upper & ~index_mask) + index;
                entry->data.reference = reference;
                entry->object = object;
                if (lock != 0)
                        *lock = &entry->lock;

/* may stay as is or: */
-                spin_unlock_bh(&entry->lock);
+		spin_unlock(&entry->lock);
+		local_bh_enable();

        }
        write_unlock_bh(&ref_table_lock);


Cheers,
Jarek P.
