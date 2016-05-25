From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] team: don't call netdev_change_features under
 team->lock
Date: Wed, 25 May 2016 17:00:40 +0200
Message-ID: <20160525150040.GA2065@nanopsycho.orion>
References: <1464188149-9383-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36178 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755374AbcEYPAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 11:00:43 -0400
Received: by mail-wm0-f50.google.com with SMTP id n129so186878391wmn.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 08:00:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1464188149-9383-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, May 25, 2016 at 04:55:49PM CEST, ivecera@redhat.com wrote:
>The team_device_event() notifier calls team_compute_features() to fix
>vlan_features under team->lock to protect team->port_list. The problem is
>that subsequent __team_compute_features() calls netdev_change_features()
>to propagate vlan_features to upper vlan devices while team->lock is still
>taken. This can lead to deadlock when NETIF_F_LRO is modified on lower
>devices or team device itself.
>
>Example:
>The team0 as active backup with eth0 and eth1 NICs. Both eth0 & eth1 are
>LRO capable and LRO is enabled. Thus LRO is also enabled on team0.
>
>The command 'ethtool -K team0 lro off' now hangs due to this deadlock:
>
>dev_ethtool()
>-> ethtool_set_features()
> -> __netdev_update_features(team)
>  -> netdev_sync_lower_features()
>   -> netdev_update_features(lower_1)
>    -> __netdev_update_features(lower_1)
>    -> netdev_features_change(lower_1)
>     -> call_netdevice_notifiers(...)
>      -> team_device_event(lower_1)
>       -> team_compute_features(team) [TAKES team->lock]
>        -> netdev_change_features(team)
>         -> __netdev_update_features(team)
>          -> netdev_sync_lower_features()
>           -> netdev_update_features(lower_2)
>            -> __netdev_update_features(lower_2)
>            -> netdev_features_change(lower_2)
>             -> call_netdevice_notifiers(...)
>              -> team_device_event(lower_2)
>               -> team_compute_features(team) [DEADLOCK]
>
>Cc: Jiri Pirko <jiri@resnulli.us>
>
>Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Please add "Fixes:" line.
Thanks!

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
