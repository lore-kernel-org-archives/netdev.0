From: Andy Zhou <azhou@ovn.org>
Subject: Re: [userspace meter v3 1/5] netdev-dummy: Add --len option for
 netdev-dummy/receive command
Date: Mon, 30 Jan 2017 23:30:45 -0800
Message-ID: <CABKoBm1-OOSo3NWN-xLgLjO41aBX5qYHhTUKyOjkkCqZ-4kzPQ@mail.gmail.com>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org> <1485844800-2873-2-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andy Zhou <azhou@ovn.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:60025 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdAaHbd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:31:33 -0500
Received: from mfilter39-d.gandi.net (mfilter39-d.gandi.net [217.70.178.170])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 40EF141C09F
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:31:30 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter39-d.gandi.net (mfilter39-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id TudcL6jFKEpe for <netdev@vger.kernel.org>;
        Tue, 31 Jan 2017 08:31:27 +0100 (CET)
Received: from mail-ua0-f180.google.com (mail-ua0-f180.google.com [209.85.217.180])
        (Authenticated sender: azhou@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 2A91041C097
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:31:27 +0100 (CET)
Received: by mail-ua0-f180.google.com with SMTP id y9so268636275uae.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:31:26 -0800 (PST)
In-Reply-To: <1485844800-2873-2-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please discard this series. These are ovs user space changes, not
kernel changes. They are sent in error. Sorry.

On Mon, Jan 30, 2017 at 10:39 PM, Andy Zhou <azhou@ovn.org> wrote:
> Currently, there is no way to specify the packet size when injecting
> a packet via "netdev-dummy/receive" with a flow specification. Thus
> far, packet size is not important for testing OVS features, but it
> becomes useful in writing unit tests for the meter implementation
> in a later patch.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  lib/netdev-dummy.c | 38 ++++++++++++++++++++++++++++----------
>  1 file changed, 28 insertions(+), 10 deletions(-)
>
> diff --git a/lib/netdev-dummy.c b/lib/netdev-dummy.c
> index e6e36cd..10df0a7 100644
> --- a/lib/netdev-dummy.c
> +++ b/lib/netdev-dummy.c
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (c) 2010, 2011, 2012, 2013, 2015, 2016 Nicira, Inc.
> + * Copyright (c) 2010, 2011, 2012, 2013, 2015, 2016, 2017 Nicira, Inc.
>   *
>   * Licensed under the Apache License, Version 2.0 (the "License");
>   * you may not use this file except in compliance with the License.
> @@ -1433,7 +1433,15 @@ pkt_list_delete(struct ovs_list *l)
>  }
>
>  static struct dp_packet *
> -eth_from_packet_or_flow(const char *s)
> +eth_from_packet(const char *s)
> +{
> +    struct dp_packet *packet;
> +    eth_from_hex(s, &packet);
> +    return packet;
> +}
> +
> +static struct dp_packet *
> +eth_from_flow(const char *s)
>  {
>      enum odp_key_fitness fitness;
>      struct dp_packet *packet;
> @@ -1441,10 +1449,6 @@ eth_from_packet_or_flow(const char *s)
>      struct flow flow;
>      int error;
>
> -    if (!eth_from_hex(s, &packet)) {
> -        return packet;
> -    }
> -
>      /* Convert string to datapath key.
>       *
>       * It would actually be nicer to parse an OpenFlow-like flow key here, but
> @@ -1540,10 +1544,24 @@ netdev_dummy_receive(struct unixctl_conn *conn,
>      for (i = k; i < argc; i++) {
>          struct dp_packet *packet;
>
> -        packet = eth_from_packet_or_flow(argv[i]);
> +        /* Try to parse 'argv[i]' as packet in hex. */
> +        packet = eth_from_packet(argv[i]);
> +
>          if (!packet) {
> -            unixctl_command_reply_error(conn, "bad packet syntax");
> -            goto exit;
> +            /* Try parse 'argv[i]' as odp flow. */
> +            packet = eth_from_flow(argv[i]);
> +
> +            if (!packet) {
> +                unixctl_command_reply_error(conn, "bad packet or flow syntax");
> +                goto exit;
> +            }
> +
> +            /* Parse optional --len argument immediately follow a 'flow'.  */
> +            if (argc >= i + 2 && !strcmp(argv[i + 1], "--len")) {
> +                int packet_size = strtol(argv[i + 2], NULL, 10);
> +                dp_packet_set_size(packet, packet_size);
> +                i+=2;
> +            }
>          }
>
>          netdev_dummy_queue_packet(dummy_dev, packet, rx_qid);
> @@ -1757,7 +1775,7 @@ void
>  netdev_dummy_register(enum dummy_level level)
>  {
>      unixctl_command_register("netdev-dummy/receive",
> -                             "name [--qid queue_id] packet|flow...",
> +                             "name [--qid queue_id] packet|flow [--len packet len]..",
>                               2, INT_MAX, netdev_dummy_receive, NULL);
>      unixctl_command_register("netdev-dummy/set-admin-state",
>                               "[netdev] up|down", 1, 2,
> --
> 1.9.1
>
