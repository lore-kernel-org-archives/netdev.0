From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next RFC 1/8] devlink: Support for pipeline debug
 (dpipe)
Date: Fri, 17 Feb 2017 09:49:07 +0100
Message-ID: <20170217084906.GA26091@penelope.horms.nl>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
 <1487258564-3775-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, arkadis@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        john.fastabend@gmail.com, andrew@lunn.ch
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:33757 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755263AbdBQItM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 03:49:12 -0500
Received: by mail-wr0-f177.google.com with SMTP id i10so25873973wrb.0
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 00:49:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1487258564-3775-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Thu, Feb 16, 2017 at 04:22:37PM +0100, Jiri Pirko wrote:
> From: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> The pipeline debug is used to export the pipeline abstractions
> for the main objects - tables, headers and entries. The only support for
> set is for changing the counter parameter on specific table.
> 
> The basic structures:
> 
> Header - can represent a real protocol header information or internal
>          metadata. Generic protocol headers like IPv4 can be shared
>          between drivers. Each driver can add local headers.
> 
> Field - part of a header. Can represent protocol field or specific
>         ASIC metadata field. Hardware special metadata fields can
>         be mapped to different resources, for example switch ASIC
>        	ports can have internal number which from the systems
>         point of view is mapped to netdeivce ifindex.
> 
> Hfield - Specific combination of header:field. This object is used
>          to represent the table behavior in terms of match/action.
> 
> Hfield_val - Represents value of specific Hfield.
> 
> Table - represents a hardware block which can be described with
>         match/action behavior. The match/action can be done on the
>         packets data or on the internal metadata that it gathered
>         along the packets traversal throw the pipeline which is vendor
>         specific and should be exported in order to provide
>         understanding of ASICs behavior.
> 
> Entry - represents single record in a specific table. The entry is
>         identified by specific combination of Hfield_vals for match
>         /action.
> 
> Prior to accessing the tables/entries the drivers provide the header/
> field data base which is used by driver to user-space. The data base
> is split between the shared headers and unique headers.

Thanks for posting this. In general I think it looks quite promising.

After a first pass over the code I have the following
specific comments:

> 
> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/devlink.h        | 224 ++++++++++++-
>  include/uapi/linux/devlink.h |  50 ++-
>  net/core/devlink.c           | 747 +++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1019 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/devlink.h b/include/net/devlink.h

...

> +/**
> + * struct devlink_dpipe_entry - table entry object
> + * @index: index of the entry in the table
> + * @matches: tuple match values
> + * @matches_count: count of matches tuples
> + * @actions: tuple actions values
> + * @actions_count: count of actions values
> + * @counter: value of counter
> + * @counter_valid: Specify if value is valid from hardware
> + */
> +struct devlink_dpipe_entry {
> +	unsigned int index;

I'm not sure what I understand what index is but I assume that it is a
unique identifier for the flow within the table. From the point of view
of having enough indexes for all entries in the table an unsigned int seems
adequate. But I see use-cases that have significantly wider identifiers.

I'm wondering what your thoughts are on supporting wider identifiers.
Perhaps they belong in the match?

> +	struct devlink_dpipe_hfield_val *matches;
> +	unsigned int matches_count;
> +	struct devlink_dpipe_hfield_val *actions;
> +	unsigned int actions_count;
> +	u64 counter;

I'm unclear on what counter is. Is it the number of times the action entry
has been used (hit)? If so I think some provision for richer per-hit
counters for entries would be useful. At least number of hits and number of
bytes.  But perhaps it would be useful to allow hardware to describe its
per-entry counters?

> +	bool counter_valid;
> +};

...
