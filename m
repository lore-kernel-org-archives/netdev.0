From: Patrick McHardy <kaber@trash.net>
Subject: Re: path: module replay
Date: Wed, 19 Jan 2005 05:26:03 +0100
Message-ID: <41EDE15B.40300@trash.net>
References: <1105900522.1090.798.camel@jzny.localdomain>	 <41EAB74F.6060507@trash.net>  <20050116185630.GZ26856@postel.suug.ch>	 <1105903033.1097.829.camel@jzny.localdomain> <1105903960.1097.836.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1105903960.1097.836.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>Ok, here is the last patch. I think module replay should be done from
>that spot and to be consistent as well from cls_api.c for legacy stuff.
>I also fixed a module ref count leak. 
>the act_api piece is dependent on what i sent earlier for namsiz.
>the cls_api change i believe conflicts with what Thomas sent yesterday.
>
+replay:
                act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
-               if (act == NULL)
-                       goto err;
+               if (act == NULL) {
+                       if (*err == -EAGAIN)
+                               goto replay;
+                       goto err_out;
+               }

This part is wrong. We can replay single action requests in the act_api init
path, but not in tcf_exts_init. We are coming from a classifier 
initialization
path and have dropped the RTNL, so we also have to replay the classifier
request.

Please send a fixed patch without the bogus module refcnt change.

Regards
Patrick
