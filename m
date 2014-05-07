From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Wed, 7 May 2014 15:26:11 -0700
Message-ID: <CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
References: <CALCETrWzUQ7QjykT85ExDfX-+9eDD-D-dcxofUMPvLK=ia9arg@mail.gmail.com>
 <87r44qrt8v.fsf_-_@x220.int.ebiederm.org> <87r44pnk3c.fsf@x220.int.ebiederm.org>
 <20140423.153216.1388028648299605195.davem@davemloft.net> <87a9bbeo2o.fsf_-_@x220.int.ebiederm.org>
 <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org> <536AB151.2070804@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f172.google.com ([209.85.128.172]:43479 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaEGW0c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 18:26:32 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz11so2195072veb.3
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 15:26:32 -0700 (PDT)
In-Reply-To: <536AB151.2070804@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 3:18 PM, Jorge Boncompte [DTI2] <jorge@dti2.net>=
 wrote:
> El 23/04/2014 23:29, Eric W. Biederman escribi=C3=B3:
>>
>> It is possible by passing a netlink socket to a more privileged
>> executable and then to fool that executable into writing to the
>> socket data that happens to be valid netlink message to do something
>> that privileged executable did not intend to do.
>>
>> To keep this from happening replace bare capable and ns_capable call=
s
>> with netlink_capable, netlink_net_calls and netlink_ns_capable calls=
=2E
>> Which act the same as the previous calls except they verify that the
>> opener of the socket had the desired permissions as well.
>>
>
>         Hi, after this patch, zebra daemon of quagga in Debian testin=
g fails to
> send routes to kernel with an -EPERM error.
>         Reverting this patch and commit a64d90fd96 (netfilter: Fix wa=
rning in
> nfnetlink_receive().) fixes it for me.
>
>         I haven't got time to do a proper analisys and could be that =
zebra
> it's doing something silly but this patch seems to subtly change some
> semantics.
>

Well, crap.

  sock =3D socket (AF_NETLINK, SOCK_RAW, NETLINK_ROUTE);
  if (sock < 0)
    {
      zlog (NULL, LOG_ERR, "Can't open %s socket: %s", nl->name,
            safe_strerror (errno));
      return -1;
    }

  memset (&snl, 0, sizeof snl);
  snl.nl_family =3D AF_NETLINK;
  snl.nl_groups =3D groups;

  /* Bind the socket to the netlink structure for anything. */
  if (zserv_privs.change (ZPRIVS_RAISE))
    {
      zlog (NULL, LOG_ERR, "Can't raise privileges");
      return -1;
    }

  ret =3D bind (sock, (struct sockaddr *) &snl, sizeof snl);
  save_errno =3D errno;
  if (zserv_privs.change (ZPRIVS_LOWER))
    zlog (NULL, LOG_ERR, "Can't lower privileges");

  if (ret < 0)
    {
      zlog (NULL, LOG_ERR, "Can't bind %s socket to group 0x%x: %s",
            nl->name, snl.nl_groups, safe_strerror (save_errno));
      close (sock);
      return -1;
    }

So what do we do?  Check permissions on connect and then use the
cached result for send on a connected socket?  Check permitted caps
instead of effective caps?

This sucks.

--Andy
