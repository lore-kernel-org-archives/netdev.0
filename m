From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net] team: team_port_add should check link_up before
 enable port
Date: Tue, 6 Dec 2016 18:38:53 +0800
Message-ID: <CADvbK_e01bz-PGmDrdxztyzLqmR5od3rahO960Oe2OhYQ6fp9w@mail.gmail.com>
References: <62f7aa9c00b68beed68a907c51dde22e7847d6c9.1481009348.git.lucien.xin@gmail.com>
 <20161206082233.GD1984@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=94eb2c0bc864c912140542fb0267
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33160 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753171AbcLFKiz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 05:38:55 -0500
Received: by mail-qt0-f195.google.com with SMTP id n6so39543224qtd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 02:38:55 -0800 (PST)
In-Reply-To: <20161206082233.GD1984@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--94eb2c0bc864c912140542fb0267
Content-Type: text/plain; charset=UTF-8

On Tue, Dec 6, 2016 at 4:22 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Dec 06, 2016 at 08:29:08AM CET, lucien.xin@gmail.com wrote:
>>Now when users add a nic to team dev, the option 'enable' of the port
>>is true by default, as team_port_enable enables it after dev_open in
>>team_port_add.
>>
>>But even if the port_dev has no carrier, like it's cable was unpluged,
>>the port is still enabled. It leads to that team dev couldn't work well
>>if this port was chosen to connect, and has no chance to change to use
>>other ports if link_watch is ethtool.
>>
>>This patch is to enable the port only when the port_dev has carrier in
>>team_port_add.
>>
>>v1 -> v2:
>>  use netif_carrier_ok() instead of !!netif_carrier_ok(), as it returns
>>  bool now.
>>
>>Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>---
>> drivers/net/team/team.c | 8 ++++++--
>> 1 file changed, 6 insertions(+), 2 deletions(-)
>>
>>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>>index a380649..4bc0103 100644
>>--- a/drivers/net/team/team.c
>>+++ b/drivers/net/team/team.c
>>@@ -1140,6 +1140,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
>>       struct net_device *dev = team->dev;
>>       struct team_port *port;
>>       char *portname = port_dev->name;
>>+      bool linkup;
>>       int err;
>>
>>       if (port_dev->flags & IFF_LOOPBACK) {
>>@@ -1249,9 +1250,12 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
>>
>>       port->index = -1;
>>       list_add_tail_rcu(&port->list, &team->port_list);
>>-      team_port_enable(team, port);
>>+      linkup = netif_carrier_ok(port_dev);
>>+      if (linkup)
>>+              team_port_enable(team, port);
>
> This is obviously wrong change. It you use a simple setup without
> userspace part (e.g. round robin), The port gets never enabled.
> team_port_enabl is called from here and team_port_en_option_set.
yes, without userspace part, that would be a problem.

>
> By default, all ports should be enabled. Only in case the userspace
> daemon decides to disable, it does so.
>
> Could you send me the exact configuration where you see the issue?
attachment is the scripts,

# ./setup.sh
# ip netns exec ns1 ./team1.sh
# ./team0.sh
# ping 192.168.11.3

the issue is team0 cannot switch to veth2, even if the veth0 has no carrier.

> This should be definitelly fixed in user part.
now it can disable/enable it in lw_ethtool_event_watch_port_changed()
when receive event from kernel, but at the beginning, the first event from
adding port will not going to team_port_en_option_set, as new_link_up
== common_ppriv->link_up in lw_ethtool_event_watch_port_changed().

maybe it should be fixed there ?

>
> Thanks.

--94eb2c0bc864c912140542fb0267
Content-Type: application/x-gzip; name="team-scripts.tar.gz"
Content-Disposition: attachment; filename="team-scripts.tar.gz"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iwddi2vo0

H4sIAB0FP1gAA+2WzXKbMBDHOfsptuSQS22zEuDWx/bcZ+jIIMeMiWCE7Eynk3evBCTlw6SXGLfT
/Vlj0O7qA6+Wv40Uj8sq0VlpqrV3HQLLZhO5K24i7F5f8JBbWxywEG0c8piFHkRX2k+PU2WEBvB2
DyI/C5VNxf3J/49iuvl3nWBVHd55jTr/0XT+Y9y85p/Hoc1/ZO89CN55Hxf5z/N/92G9y9S6OiwW
LvspLA3UxwCWx5HF3idw/xN8fVJKah+2YDtKPEp/C35eiHQncqES6cPzR7CWTB2/PwmTHAah0hxM
UeQ2DJ7vF1kJOVTSwNnaA0iLJ9W3scY2DBRpqiEItrZh/V234dB+FGNNax83MXn7cGWhjYtt5n7T
y0Y7OZXDVbuWZgprcSZhP6k8t0b8zFYYf1ohrnDNwsXs+e/Vv93sqZy//sPo9/ufY+zqn7OA6n8O
OvV/B1+1FEbWJxhKkemqOcOvVQHmR/nillKDK+e6i/1ANhnI3TLfinM7DIRqRnAwhSuMbL+XWioD
ql5bSaOqelpVYb/EsHWOHLzjsIt90Zl6sMUHmTJS70Ui65mXygX05mtKduTgdeXeOk/XYqT/eAP9
j+PB/7+IBVT/szCl/zjSf5xH//GC/vNL+o8DZUds2nBoP4rzpg30H/sKj296+WgnQ/3nI/3HS/qP
Xf3nTv/tC+soZTn5S7S2W58agiAIgiAIgiAIgiAIgiAIgiAI4m/lF97ircEAKAAA
--94eb2c0bc864c912140542fb0267--
