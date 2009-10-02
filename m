From: Lars Ellenberg <lars.ellenberg@linbit.com>
Subject: Re: [PATCH 0/8] SECURITY ISSUE with connector
Date: Fri, 2 Oct 2009 18:21:21 +0200
Message-ID: <20091002162121.GA8020@mail.linbit.com>
References: <1254487211-11810-1-git-send-email-philipp.reisner@linbit.com>
	<20091002135859.GA9383@kroah.com>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fbdev-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Philipp Reisner <philipp.reisner@linbit.com>,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, Alasdair G Kergon <agk@redhat.com>
To: Greg KH <greg@kroah.com>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20091002135859.GA9383@kroah.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2009 at 06:58:59AM -0700, Greg KH wrote:
> On Fri, Oct 02, 2009 at 02:40:03PM +0200, Philipp Reisner wrote:
> > Affected: All code that uses connector, in kernel and out of mainline
> > 
> > The connector, as it is today, does not allow the in kernel receiving
> > parts to do any checks on privileges of a message's sender.
> 
> So, assume I know nothing about the connector architecture, what does
> this mean in a security context?

Arbitrary unprivileged users may craft a netlink message, which gets delivered
through connector to callbacks (registered in kernel with cn_add_callback).

These callbacks will then act on the message, as if it originated from an
"expected" source.  But currently there is no mechanism to verify the origin, 
even if the callbacks would try to.

> > I know, there are not many out there that like connector, but as
> > long as it is in the kernel, we have to fix the security issues it has!
> 
> And what specifically are the security issues?

For the cn_ulog_callback (dm-log-userspace-transfer.c),
someone would be able to fake completion (with or without error code)
of ulog entries, copying arbitrary data into receiving_pkg entries.

   /*
    * This is the connector callback that delivers data
    * that was sent from userspace.
    */
   static void cn_ulog_callback(void *data)
   {
           struct cn_msg *msg = (struct cn_msg *)data;
           struct dm_ulog_request *tfr = (struct dm_ulog_request *)(msg + 1);
   
           spin_lock(&receiving_list_lock);
           if (msg->len == 0)
                   fill_pkg(msg, NULL);
           else if (msg->len < sizeof(*tfr))
                   DMERR("Incomplete message received (expected %u, got %u): [%u]",
                         (unsigned)sizeof(*tfr), msg->len, msg->seq);
           else
                   fill_pkg(NULL, tfr);
           spin_unlock(&receiving_list_lock);
   }
   
   static int fill_pkg(struct cn_msg *msg, struct dm_ulog_request *tfr)
   {
           uint32_t rtn_seq = (msg) ? msg->seq : (tfr) ? tfr->seq : 0;
   ...
                   } else {
                           pkg->error = tfr->error;
                           memcpy(pkg->data, tfr->data, tfr->data_size);
                           *(pkg->data_size) = tfr->data_size;
                   }
                   complete(&pkg->complete);

   
   
should make that obvious: if an unprivileged user can deliver arbitrary msg to
cn_ulog_callback, that should at least be disruptive to services that use it.

fix: check origin of message for proper credentials (e.g. CAP_SYS_ADMIN).




what or how much damage a crafted message can do in uvesafb_cn_callback,
I'm not sure. But, if I get the msg->seq right, and get by the first
sanity check, again, arbitrary input is copied into some
kernel object, which will likely at least confuse that subsystem,
maybe do damage, or result in some sort of denial of service.

I just don't know what these uvesafb_ktask do, but I doubt that anyone but root
should be able to manipulate them.




in the case of dst and pohemlfs, it is (re|de) configuration of respective in
kernel objects, possibly exposing arbitrary data content
	@Evgeniy - is that statement correct? Does something prevent an
	unprivileged user to export arbitrary things via dst?
At least some sort of denial of service should be possible there.

for DRBD, we have of course similar problems as long as we use the connector
in its current form as our configuration choice.



I'm not sure what actual harm can be done by arbitrary calling
w1_reset_select_slave(), or w1_process_command_io(),
but allowing unprivileged users to meddle with arbitrary devices is most likely
not the intended behaviour there, either.


The "obvious" way was to first make the credentials and capabilities of the
message origin available to these callbacks, and then test on "CAP_SYS_ADMIN".


Note that the suggested usage of the connector for _userspace_ tools
is to bind() to some netlink socket, subscribing to apropriate mutlicast
groups, which will usually fail for unprivileged users in netlink_bind()
because of

        /* Only superuser is allowed to listen multicasts */
        if (nladdr->nl_groups) {
                if (!netlink_capable(sock, NL_NONROOT_RECV))
                        return -EPERM;
                err = netlink_realloc_groups(sk);
                if (err)
                        return err;
        }

So typical userspace tools will fail when used as non-root.
But if you leave out the bind, you are perfectly able to _send_ arbitrary
messages on that socket, even if you are not able to receive any replies from
connector kernel space in that case.



Cheers,

	Lars
