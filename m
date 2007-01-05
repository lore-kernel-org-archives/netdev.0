From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH] tipc: checking returns and Re: Possible Circular Locking
 in TIPC
Date: Fri, 05 Jan 2007 17:22:52 +0000
Message-ID: <459E896C.4050309@ericsson.com>
References: <20061228121702.GA5076@ff.dom.local> <459C396B.1090508@ericsson.com> <20070104122843.GC3175@ff.dom.local> <459D2854.1000405@ericsson.com> <20070105075857.GB1675@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn <snakebyte@gmx.de>,
	Per Liden <per.liden@ericsson.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"'tipc-discussion@lists.sourceforge.net'"
	<tipc-discussion@lists.sourceforge.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422641AbXAER0Q@vger.kernel.org>
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070105075857.GB1675@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:

>
>If you are sure there is no circular locking possible
>between these two functions and this entry->lock here
>isn't endangered by other functions, you could try to
>make lockdep "silent" like this: 
>
>
>        write_lock_bh(&ref_table_lock);
>        if (tipc_ref_table.first_free) {
>                index = tipc_ref_table.first_free;
>                entry = &(tipc_ref_table.entries[index]);
>                index_mask = tipc_ref_table.index_mask;
>                /* take lock in case a previous user of entry still holds it */
>
>-                spin_lock_bh(&entry->lock, );
>+		local_bh_disable();
>+		spin_lock_nested(&entry->lock, SINGLE_DEPTH_NESTING);
>
>                next_plus_upper = entry->data.next_plus_upper;
>                tipc_ref_table.first_free = next_plus_upper & index_mask;
>                reference = (next_plus_upper & ~index_mask) + index;
>                entry->data.reference = reference;
>                entry->object = object;
>                if (lock != 0)
>                        *lock = &entry->lock;
>
>/* may stay as is or: */
>-                spin_unlock_bh(&entry->lock);
>+		spin_unlock(&entry->lock);
>+		local_bh_enable();
>
>        }
>        write_unlock_bh(&ref_table_lock);
>
>
>  
>
Looks like an acceptable solution. I will try this.
Thanks
///Jon
