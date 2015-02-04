From: Andy Zhou <azhou@nicira.com>
Subject: [RFC: add openvswitch actions using BPF 9/9] ofproto-dpif-xlate: generate BPF output action (Hack)
Date: Wed,  4 Feb 2015 14:49:23 -0800
Message-ID: <1423090163-19902-10-git-send-email-azhou@nicira.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: dev@openvswitch.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:37012 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965179AbbBDXUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 18:20:42 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so3682880pde.3
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 15:20:42 -0800 (PST)
In-Reply-To: <1423090163-19902-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a hack in xlate code to always generate both BPF output
and the original output action. Since the currnet BPF output 'action'
simply generate a kenrel log message about the output port number.

With this patch, Every time datapath output a packet, it also generate
log about the port number in the kernel log.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 ofproto/ofproto-dpif-xlate.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 0786513..41a7502 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -15,6 +15,7 @@
 #include <config.h>
 
 #include "ofproto/ofproto-dpif-xlate.h"
+#include "ofproto/ofproto-dpif-bpf.h"
 
 #include <errno.h>
 #include <arpa/inet.h>
@@ -2833,14 +2834,27 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
                                         OVS_ACTION_ATTR_TUNNEL_POP,
                                         odp_tnl_port);
                 } else {
+                    int fd;
+                    struct ovs_action_bpf_prog bpf_output;
+
+                    fd = ofproto_dpif_bpf_lookup("ovs/output");
+
+                    if (fd > 0) {
+                        bpf_output.prog_fd = htonl(fd);
+                        bpf_output.arg0 = htonl(out_port);
+                        bpf_output.arg1 = htonl(0);
+                        nl_msg_push_unspec(ctx->xout->odp_actions,
+                                           OVS_ACTION_ATTR_BPF_PROG,
+                                           &bpf_output, sizeof(bpf_output));
+                    }
                     /* Tunnel push-pop action is not compatible with
                      * IPFIX action. */
                     add_ipfix_output_action(ctx, out_port);
                     nl_msg_put_odp_port(ctx->xout->odp_actions,
                                         OVS_ACTION_ATTR_OUTPUT,
                                         out_port);
-               }
-           }
+                }
+            }
         }
 
         ctx->sflow_odp_port = odp_port;
-- 
1.9.1
