From: Richard Haines <richard_c_haines@btinternet.com>
Subject: Re: [RFC PATCH 1/5] security: Add support for SCTP security hooks
Date: Wed, 01 Nov 2017 21:38:23 +0000
Message-ID: <1509572303.2954.8.camel@btinternet.com>
References: <20171017140247.4604-1-richard_c_haines@btinternet.com>
         <20171031164153.GC3675@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-security-module@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgout06.bt.lon5.cpcloud.co.uk ([65.20.0.183]:64497 "EHLO
        rgout06.bt.lon5.cpcloud.co.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934364AbdKAVib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:38:31 -0400
In-Reply-To: <20171031164153.GC3675@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-31 at 14:41 -0200, Marcelo Ricardo Leitner wrote:
> On Tue, Oct 17, 2017 at 03:02:47PM +0100, Richard Haines wrote:
> > The SCTP security hooks are explained in:
> > Documentation/security/LSM-sctp.txt
> > 
> > Signed-off-by: Richard Haines <richard_c_haines@btinternet.com>
> > ---
> >  Documentation/security/LSM-sctp.txt | 212
> > ++++++++++++++++++++++++++++++++++++
> >  include/linux/lsm_hooks.h           |  37 +++++++
> >  include/linux/security.h            |  27 +++++
> >  security/security.c                 |  23 ++++
> >  4 files changed, 299 insertions(+)
> >  create mode 100644 Documentation/security/LSM-sctp.txt
> > 
> > diff --git a/Documentation/security/LSM-sctp.txt
> > b/Documentation/security/LSM-sctp.txt
> > new file mode 100644
> > index 0000000..30fe9b5
> > --- /dev/null
> > +++ b/Documentation/security/LSM-sctp.txt
> > @@ -0,0 +1,212 @@
> > +                               SCTP LSM Support
> > +                              ==================
> > +
> > +For security module support, three sctp specific hooks have been
> > implemented:
> > +    security_sctp_assoc_request()
> > +    security_sctp_bind_connect()
> > +    security_sctp_sk_clone()
> > +
> > +Also the following security hook has been utilised:
> > +    security_inet_conn_established()
> > +
> > +The usage of these hooks are described below with the SELinux
> > implementation
> > +described in Documentation/security/SELinux-sctp.txt
> > +
> > +
> > +security_sctp_assoc_request()
> > +------------------------------
> > +This new hook has been added to net/sctp/sm_statefuns.c where it
> > passes the
> > +@ep and @chunk->skb (the association INIT or INIT ACK packet) to
> > the security
> > +module. Returns 0 on success, error on failure.
> > +
> > +    @ep - pointer to sctp endpoint structure.
> > +    @skb - pointer to skbuff of association packet.
> > +    @sctp_cid - set to sctp packet type (SCTP_CID_INIT or
> > SCTP_CID_INIT_ACK).
> > +
> > +The security module performs the following operations:
> > +  1) If this is the first association on @ep->base.sk, then set
> > the peer sid
> > +     to that in @skb. This will ensure there is only one peer sid
> > assigned
> > +     to @ep->base.sk that may support multiple associations.
> > +
> > +  2) If not the first association, validate the @ep->base.sk
> > peer_sid against
> > +     the @skb peer sid to determine whether the association should
> > be allowed
> > +     or denied.
> > +
> > +  3) If @sctp_cid = SCTP_CID_INIT, then set the sctp @ep sid to
> > socket's sid
> > +     (from ep->base.sk) with MLS portion taken from @skb peer sid.
> > This will
> > +     only be used by SCTP TCP style sockets and peeled off
> > connections as they
> > +     cause a new socket to be generated.
> > +
> > +     If IP security options are configured (CIPSO/CALIPSO), then
> > the ip options
> > +     are set on the socket.
> > +
> > +     To support this hook include/net/sctp/structs.h "struct
> > sctp_endpoint"
> > +     has been updated with the following:
> > +
> > +	/* Security identifiers from incoming (INIT). These are
> > set by
> > +	 * security_sctp_assoc_request(). These will only be used
> > by
> > +	 * SCTP TCP type sockets and peeled off connections as
> > they
> > +	 * cause a new socket to be generated.
> > security_sctp_sk_clone()
> > +	 * will then plug these into the new socket.
> > +	 */
> > +	u32 secid;
> > +	u32 peer_secid;
> > +
> > +
> > +security_sctp_bind_connect()
> > +-----------------------------
> > +This new hook has been added to net/sctp/socket.c and
> > net/sctp/sm_make_chunk.c.
> > +It passes one or more ipv4/ipv6 addresses to the security module
> > for
> > +validation based on the @optname that will result in either a bind
> > or connect
> > +service as shown in the permission check tables below.
> > +Returns 0 on success, error on failure.
> > +
> > +    @sk      - Pointer to sock structure.
> > +    @optname - Name of the option to validate.
> > +    @address - One or more ipv4 / ipv6 addresses.
> > +    @addrlen - The total length of address(s). This is calculated
> > on each
> > +               ipv4 or ipv6 address using sizeof(struct
> > sockaddr_in) or
> > +               sizeof(struct sockaddr_in6).
> > +
> > +  --------------------------------------------------------------
> > ----
> > +  |                     BIND Type
> > Checks                           |
> > +  |       @optname             |         @address
> > contains         |
> > +  |----------------------------|--------------------------------
> > ---|
> > +  | SCTP_SOCKOPT_BINDX_ADD     | One or more ipv4 / ipv6 addresses
> > |
> > +  | SCTP_PRIMARY_ADDR          | Single ipv4 or ipv6
> > address       |
> > +  | SCTP_SET_PEER_PRIMARY_ADDR | Single ipv4 or ipv6
> > address       |
> > +  --------------------------------------------------------------
> > ----
> > +
> > +  --------------------------------------------------------------
> > ----
> > +  |                   CONNECT Type
> > Checks                          |
> > +  |       @optname             |         @address
> > contains         |
> > +  |----------------------------|--------------------------------
> > ---|
> > +  | SCTP_SOCKOPT_CONNECTX      | One or more ipv4 / ipv6 addresses
> > |
> > +  | SCTP_PARAM_ADD_IP          | One or more ipv4 / ipv6 addresses
> > |
> > +  | SCTP_SENDMSG_CONNECT       | Single ipv4 or ipv6
> > address       |
> > +  | SCTP_PARAM_SET_PRIMARY     | Single ipv4 or ipv6
> > address       |
> > +  --------------------------------------------------------------
> > ----
> > +
> > +A summary of the @optname entries is as follows:
> > +
> > +    SCTP_SOCKOPT_BINDX_ADD - Allows additional bind addresses to
> > be
> > +                             associated after (optionally) calling
> > +                             bind(3).
> > +                             sctp_bindx(3) adds a set of bind
> > +	                     addresses on a socket.
> 
> Nit, indentation issue above.
The nit has been squashed
Thanks for all your comments
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-
> security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
