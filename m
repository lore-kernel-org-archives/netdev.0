From: jamal <hadi@cyberus.ca>
Subject: path: module replay
Date: 16 Jan 2005 14:32:40 -0500
Message-ID: <1105903960.1097.836.camel@jzny.localdomain>
References: <1105900522.1090.798.camel@jzny.localdomain>
	 <41EAB74F.6060507@trash.net>  <20050116185630.GZ26856@postel.suug.ch>
	 <1105903033.1097.829.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-z7lhh1ujrqFdR43zqEYn"
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <1105903033.1097.829.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-z7lhh1ujrqFdR43zqEYn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Sorry, that work address just decides to appear when it feels like it.
Doing this from my laptop which is also used for work (as well as extra
curicular activities ;->). Now if evolution could setup the From address
for me when posting to netdev it would help ;->

On Sun, 2005-01-16 at 14:17, Jamal Hadi Salim wrote:
> On my part - theres one little change i made - just compiling it as we
> speak;
> I will post and stop there until you are done


Ok, here is the last patch. I think module replay should be done from
that spot and to be consistent as well from cls_api.c for legacy stuff.
I also fixed a module ref count leak. 
the act_api piece is dependent on what i sent earlier for namsiz.
the cls_api change i believe conflicts with what Thomas sent yesterday.
Anyways, not sending anymore after this ;->

cheers,
jamal

--=-z7lhh1ujrqFdR43zqEYn
Content-Disposition: attachment; filename=p_replay
Content-Type: text/plain; name=p_replay; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/net/sched/act_api.c	2005/01/16 14:05:37	1.2
+++ b/net/sched/act_api.c	2005/01/16 14:22:47
@@ -308,7 +308,7 @@
 		 */
 		if (a_o != NULL) {
 			*err = -EAGAIN;
-			goto err_mod;
+			goto err_out;
 		}
 #endif
 		goto err_out;
@@ -361,9 +361,13 @@
 	}
 
 	for (i=0; i < TCA_ACT_MAX_PRIO && tb[i]; i++) {
+replay:
 		act = tcf_action_init_1(tb[i], est, name, ovr, bind, err);
-		if (act == NULL)
-			goto err;
+		if (act == NULL) {
+			if (*err == -EAGAIN)
+				goto replay;
+			goto err_out;
+		}
 		act->order = i+1;
 
 		if (head == NULL)
@@ -374,7 +378,7 @@
 	}
 	return head;
 
-err:
+err_out:
 	if (head != NULL)
 		tcf_action_destroy(head, bind);
 	return NULL;
@@ -752,10 +756,7 @@
 		 */
 		if (n->nlmsg_flags&NLM_F_REPLACE)
 			ovr = 1;
-replay:
 		ret = tcf_action_add(tca[TCA_ACT_TAB-1], n, pid, ovr);
-		if (ret == -EAGAIN)
-			goto replay;
 		break;
 	case RTM_DELACTION:
 		ret = tca_action_gd(tca[TCA_ACT_TAB-1], n, pid, RTM_DELACTION);
--- a/net/sched/cls_api.c	2005/01/16 14:09:39	1.1
+++ b/net/sched/cls_api.c	2005/01/16 14:20:41
@@ -486,14 +486,19 @@
 	memset(exts, 0, sizeof(*exts));
 	
 #ifdef CONFIG_NET_CLS_ACT
+	{
 	int err;
 	struct tc_action *act;
 
 	if (map->police && tb[map->police-1]) {
+replay:
 		act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
 			TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
-		if (act == NULL)
-			return err;
+			if (act == NULL) {
+				if (err == -EAGAIN)
+					goto replay;
+				return err;
+			}
 
 		act->type = TCA_OLD_COMPAT;
 		exts->action = act;
@@ -505,6 +510,7 @@
 
 		exts->action = act;
 	}
+	}
 #elif defined CONFIG_NET_CLS_POLICE
 	if (map->police && tb[map->police-1]) {
 		struct tcf_police *p;

--=-z7lhh1ujrqFdR43zqEYn--
